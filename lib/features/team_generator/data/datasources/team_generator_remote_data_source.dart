import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../domain/engine/team_balancer.dart';
import '../../domain/entities/team_lineup_entity.dart';
import '../models/team_lineup_model.dart';

abstract class TeamGeneratorRemoteDataSource {
  Future<TeamLineupModel> generateBalancedTeams({
    required List<PlayerEntity> players,
    required String matchId,
  });

  Future<TeamLineupModel> swapPlayers({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  });

  Future<TeamLineupModel> saveFinalLineup(TeamLineupEntity lineup);

  Future<List<TeamLineupModel>> getLineupHistory({String? matchId});
}

class FirebaseTeamGeneratorRemoteDataSource
    implements TeamGeneratorRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseTeamGeneratorRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _lineupsCollection =>
      _firestore.collection('team_lineups');

  @override
  Future<TeamLineupModel> generateBalancedTeams({
    required List<PlayerEntity> players,
    required String matchId,
  }) async {
    try {
      final lineup = TeamBalancer.balance(players: players, matchId: matchId);
      return TeamLineupModel.fromEntity(lineup);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TeamLineupModel> swapPlayers({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  }) async {
    try {
      final swapped = TeamBalancer.swap(
        lineup: lineup,
        playerAId: playerAId,
        playerBId: playerBId,
      );
      return TeamLineupModel.fromEntity(swapped);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TeamLineupModel> saveFinalLineup(TeamLineupEntity lineup) async {
    try {
      final finalized = lineup.copyWith(isFinalized: true);
      final model = TeamLineupModel.fromEntity(finalized);
      await _lineupsCollection.doc(model.id).set(model.toJson());
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TeamLineupModel>> getLineupHistory({String? matchId}) async {
    try {
      Query<Map<String, dynamic>> query = _lineupsCollection.orderBy(
        'generatedAt',
        descending: true,
      );
      if (matchId != null) {
        query = query.where('matchId', isEqualTo: matchId);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TeamLineupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

/// Pre-seeded mock data source for testing and immediate offline operations.
class MockTeamGeneratorRemoteDataSource
    implements TeamGeneratorRemoteDataSource {
  final Map<String, TeamLineupModel> _history = {};
  final Duration delay;

  MockTeamGeneratorRemoteDataSource({this.delay = Duration.zero});

  @override
  Future<TeamLineupModel> generateBalancedTeams({
    required List<PlayerEntity> players,
    required String matchId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final lineup = TeamBalancer.balance(players: players, matchId: matchId);
    final model = TeamLineupModel.fromEntity(lineup);
    _history[model.id] = model;
    return model;
  }

  @override
  Future<TeamLineupModel> swapPlayers({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final swapped = TeamBalancer.swap(
      lineup: lineup,
      playerAId: playerAId,
      playerBId: playerBId,
    );
    final model = TeamLineupModel.fromEntity(swapped);
    _history[model.id] = model;
    return model;
  }

  @override
  Future<TeamLineupModel> saveFinalLineup(TeamLineupEntity lineup) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final finalized = lineup.copyWith(isFinalized: true);
    final model = TeamLineupModel.fromEntity(finalized);
    _history[model.id] = model;
    return model;
  }

  @override
  Future<List<TeamLineupModel>> getLineupHistory({String? matchId}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    var list = _history.values.toList();
    if (matchId != null) {
      list = list.where((l) => l.matchId == matchId).toList();
    }
    return list;
  }
}

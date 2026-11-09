import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../models/group_leaderboard_model.dart';
import '../models/player_stats_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<GroupLeaderboardModel> getGroupLeaderboards();

  Future<PlayerStatsModel> getPlayerStats(String playerId);
}

class FirebaseStatisticsRemoteDataSource implements StatisticsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseStatisticsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<GroupLeaderboardModel> getGroupLeaderboards() async {
    try {
      final doc = await _firestore
          .collection('statistics')
          .doc('group_leaderboard')
          .get();
      if (!doc.exists) {
        return const GroupLeaderboardModel(
          topScorers: [],
          topAssisters: [],
          topCleanSheets: [],
          topMotm: [],
          allPlayers: [],
          totalMatches: 0,
          totalGoals: 0,
        );
      }
      return GroupLeaderboardModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerStatsModel> getPlayerStats(String playerId) async {
    try {
      final doc = await _firestore
          .collection('player_statistics')
          .doc(playerId)
          .get();
      if (!doc.exists) {
        throw NotFoundException('إحصائيات اللاعب غير موجودة');
      }
      return PlayerStatsModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }
}

/// Pre-seeded in-memory mock data source for immediate offline operation and testing.
class MockStatisticsRemoteDataSource implements StatisticsRemoteDataSource {
  final Map<String, PlayerStatsModel> _playerStats = {};
  final Duration delay;

  MockStatisticsRemoteDataSource({this.delay = Duration.zero}) {
    _seedDefaultStats();
  }

  void _seedDefaultStats() {
    final players = [
      const PlayerStatsModel(
        playerId: 'p3',
        playerName: 'سفيان العلي',
        position: PlayerPosition.forward,
        matchesPlayed: 14,
        goals: 18,
        assists: 7,
        cleanSheets: 0,
        motmAwards: 4,
        wins: 10,
        draws: 2,
        losses: 2,
      ),
      const PlayerStatsModel(
        playerId: 'p1',
        playerName: 'مروان سمير',
        position: PlayerPosition.midfielder,
        matchesPlayed: 15,
        goals: 11,
        assists: 16,
        cleanSheets: 2,
        motmAwards: 5,
        wins: 11,
        draws: 3,
        losses: 1,
      ),
      const PlayerStatsModel(
        playerId: 'p2',
        playerName: 'فهد الدوسري',
        position: PlayerPosition.goalkeeper,
        matchesPlayed: 16,
        goals: 0,
        assists: 1,
        cleanSheets: 8,
        motmAwards: 3,
        wins: 12,
        draws: 2,
        losses: 2,
      ),
      const PlayerStatsModel(
        playerId: 'p4',
        playerName: 'طارق حامد',
        position: PlayerPosition.midfielder,
        matchesPlayed: 12,
        goals: 6,
        assists: 8,
        cleanSheets: 3,
        motmAwards: 1,
        wins: 8,
        draws: 2,
        losses: 2,
      ),
      const PlayerStatsModel(
        playerId: 'p5',
        playerName: 'عمر الشهري',
        position: PlayerPosition.defender,
        matchesPlayed: 13,
        goals: 3,
        assists: 4,
        cleanSheets: 6,
        motmAwards: 1,
        wins: 9,
        draws: 1,
        losses: 3,
      ),
      const PlayerStatsModel(
        playerId: 'p6',
        playerName: 'كابتن زياد',
        position: PlayerPosition.forward,
        matchesPlayed: 10,
        goals: 9,
        assists: 3,
        cleanSheets: 0,
        motmAwards: 2,
        wins: 6,
        draws: 2,
        losses: 2,
      ),
    ];

    for (final p in players) {
      _playerStats[p.playerId] = p;
    }
  }

  @override
  Future<GroupLeaderboardModel> getGroupLeaderboards() async {
    if (delay > Duration.zero) await Future.delayed(delay);

    final all = _playerStats.values.toList();

    final topScorers = List<PlayerStatsModel>.from(all)
      ..sort((a, b) => b.goals.compareTo(a.goals));

    final topAssisters = List<PlayerStatsModel>.from(all)
      ..sort((a, b) => b.assists.compareTo(a.assists));

    final topCleanSheets = List<PlayerStatsModel>.from(all)
      ..sort((a, b) => b.cleanSheets.compareTo(a.cleanSheets));

    final topMotm = List<PlayerStatsModel>.from(all)
      ..sort((a, b) => b.motmAwards.compareTo(a.motmAwards));

    final totalGoals = all.fold(0, (acc, p) => acc + p.goals);

    return GroupLeaderboardModel(
      topScorers: topScorers,
      topAssisters: topAssisters,
      topCleanSheets: topCleanSheets,
      topMotm: topMotm,
      allPlayers: all,
      totalMatches: 24,
      totalGoals: totalGoals,
    );
  }

  @override
  Future<PlayerStatsModel> getPlayerStats(String playerId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final stats = _playerStats[playerId];
    if (stats == null) throw NotFoundException('إحصائيات اللاعب غير متوفرة');
    return stats;
  }
}

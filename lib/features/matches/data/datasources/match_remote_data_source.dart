import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/registration_status.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/match_registration_entity.dart';
import '../models/match_model.dart';
import '../models/match_registration_model.dart';
import '../models/match_result_model.dart';

abstract class MatchRemoteDataSource {
  Future<List<MatchModel>> getMatches({MatchStatus? status});

  Future<MatchModel> getMatchById(String matchId);

  Future<MatchModel> createMatch(MatchModel match);

  Future<MatchModel> registerPlayer({
    required String matchId,
    required String playerId,
    required String playerName,
    required PlayerPosition position,
  });

  Future<MatchModel> cancelRegistration({
    required String matchId,
    required String playerId,
  });

  Future<MatchResultModel> recordMatchResult(MatchResultModel result);

  Future<MatchResultModel?> getMatchResult(String matchId);

  Stream<MatchModel?> watchMatch(String matchId);
}

class FirebaseMatchRemoteDataSource implements MatchRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseMatchRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _matchesCollection =>
      _firestore.collection('matches');

  @override
  Future<List<MatchModel>> getMatches({MatchStatus? status}) async {
    try {
      Query<Map<String, dynamic>> query = _matchesCollection.orderBy(
        'matchDateTime',
      );
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> getMatchById(String matchId) async {
    try {
      final doc = await _matchesCollection.doc(matchId).get();
      if (!doc.exists) {
        throw const AppException('المباراة غير موجودة');
      }
      return MatchModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> createMatch(MatchModel match) async {
    try {
      final docRef = _matchesCollection.doc(match.id.isEmpty ? null : match.id);
      final finalMatch = match.id.isEmpty
          ? MatchModel.fromEntity(match.copyWith(id: docRef.id))
          : match;
      await docRef.set(finalMatch.toJson());
      return finalMatch;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> registerPlayer({
    required String matchId,
    required String playerId,
    required String playerName,
    required PlayerPosition position,
  }) async {
    final match = await getMatchById(matchId);

    if (match.isPlayerRegistered(playerId)) {
      throw const AppException(
        'اللاعب مسجل بالفعل في هذه المباراة',
        'DUPLICATE_REGISTRATION',
      );
    }

    final now = DateTime.now();
    final regId = 'reg_${now.millisecondsSinceEpoch}';

    List<MatchRegistrationEntity> updatedConfirmed = List.from(
      match.confirmedPlayers,
    );
    List<MatchRegistrationEntity> updatedWaiting = List.from(match.waitingList);
    MatchStatus updatedStatus = match.status;

    if (updatedConfirmed.length < match.maxPlayers) {
      updatedConfirmed.add(
        MatchRegistrationModel(
          id: regId,
          matchId: matchId,
          playerId: playerId,
          playerName: playerName,
          playerPosition: position,
          registeredAt: now,
          status: RegistrationStatus.confirmed,
        ),
      );
      if (updatedConfirmed.length >= match.maxPlayers) {
        updatedStatus = MatchStatus.full;
      }
    } else {
      updatedWaiting.add(
        MatchRegistrationModel(
          id: regId,
          matchId: matchId,
          playerId: playerId,
          playerName: playerName,
          playerPosition: position,
          registeredAt: now,
          status: RegistrationStatus.waiting,
          queuePosition: updatedWaiting.length + 1,
        ),
      );
    }

    final updatedMatch = match.copyWith(
      confirmedPlayers: updatedConfirmed,
      waitingList: updatedWaiting,
      status: updatedStatus,
    );

    await _matchesCollection
        .doc(matchId)
        .set(MatchModel.fromEntity(updatedMatch).toJson());
    return MatchModel.fromEntity(updatedMatch);
  }

  @override
  Future<MatchModel> cancelRegistration({
    required String matchId,
    required String playerId,
  }) async {
    final match = await getMatchById(matchId);

    List<MatchRegistrationEntity> updatedConfirmed = List.from(
      match.confirmedPlayers,
    );
    List<MatchRegistrationEntity> updatedWaiting = List.from(match.waitingList);

    final wasConfirmed = updatedConfirmed.any((r) => r.playerId == playerId);
    updatedConfirmed.removeWhere((r) => r.playerId == playerId);
    updatedWaiting.removeWhere((r) => r.playerId == playerId);

    // If confirmed player left and there are people waiting, promote #1 waiting player!
    if (wasConfirmed && updatedWaiting.isNotEmpty) {
      final promoted = updatedWaiting.removeAt(0);
      updatedConfirmed.add(
        promoted.copyWith(
          status: RegistrationStatus.confirmed,
          clearQueuePosition: true,
        ),
      );
    }

    // Re-index remaining waiting list
    final reindexedWaiting = <MatchRegistrationEntity>[];
    for (int i = 0; i < updatedWaiting.length; i++) {
      reindexedWaiting.add(updatedWaiting[i].copyWith(queuePosition: i + 1));
    }

    MatchStatus newStatus = match.status;
    if (updatedConfirmed.length < match.maxPlayers &&
        newStatus == MatchStatus.full) {
      newStatus = MatchStatus.upcoming;
    }

    final updatedMatch = match.copyWith(
      confirmedPlayers: updatedConfirmed,
      waitingList: reindexedWaiting,
      status: newStatus,
    );

    await _matchesCollection
        .doc(matchId)
        .set(MatchModel.fromEntity(updatedMatch).toJson());
    return MatchModel.fromEntity(updatedMatch);
  }

  @override
  Future<MatchResultModel> recordMatchResult(MatchResultModel result) async {
    try {
      final docRef = _firestore.collection('match_results').doc(result.id);
      await docRef.set(result.toJson());

      // Update match document with completed status and result payload
      await _matchesCollection.doc(result.matchId).update({
        'status': MatchStatus.completed.name,
        'result': result.toJson(),
      });

      return result;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchResultModel?> getMatchResult(String matchId) async {
    try {
      final doc = await _firestore
          .collection('match_results')
          .doc(matchId)
          .get();
      if (!doc.exists) return null;
      return MatchResultModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<MatchModel?> watchMatch(String matchId) {
    return _matchesCollection.doc(matchId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MatchModel.fromFirestore(doc);
    });
  }
}

/// Pre-seeded in-memory mock data source for testing and immediate offline operations.
class MockMatchRemoteDataSource implements MatchRemoteDataSource {
  final Map<String, MatchModel> _matches = {};
  final Map<String, MatchResultModel> _results = {};
  final _streamController = StreamController<MatchModel?>.broadcast();
  final Duration delay;

  MockMatchRemoteDataSource({this.delay = Duration.zero}) {
    _seedDefaultMatches();
  }

  void _seedDefaultMatches() {
    final now = DateTime.now();

    final m1 = MatchModel(
      id: 'm1',
      title: 'مباراة الجمعة الكبرى',
      pitchName: 'ملعب النخبة الدولي (Elite Turf Arena)',
      location: 'المنطقة المركزية • 0.8 كم',
      matchDateTime: now.add(const Duration(days: 2, hours: 19)),
      maxPlayers: 18,
      feePerPlayer: 35.0,
      status: MatchStatus.upcoming,
      courtType: 'صالة مغطاة (عشب صناعي)',
      pitchDimensions: '25 × 40 m',
      confirmedPlayers: [
        MatchRegistrationModel(
          id: 'r1',
          matchId: 'm1',
          playerId: 'p1',
          playerName: 'مروان سمير',
          playerPosition: PlayerPosition.midfielder,
          registeredAt: now.subtract(const Duration(hours: 5)),
          status: RegistrationStatus.confirmed,
        ),
        MatchRegistrationModel(
          id: 'r2',
          matchId: 'm1',
          playerId: 'p2',
          playerName: 'عصام الحضري',
          playerPosition: PlayerPosition.goalkeeper,
          registeredAt: now.subtract(const Duration(hours: 4)),
          status: RegistrationStatus.confirmed,
        ),
        MatchRegistrationModel(
          id: 'r3',
          matchId: 'm1',
          playerId: 'p3',
          playerName: 'وائل جمعة',
          playerPosition: PlayerPosition.defender,
          registeredAt: now.subtract(const Duration(hours: 3)),
          status: RegistrationStatus.confirmed,
        ),
        MatchRegistrationModel(
          id: 'r4',
          matchId: 'm1',
          playerId: 'p4',
          playerName: 'محمد بركات',
          playerPosition: PlayerPosition.midfielder,
          registeredAt: now.subtract(const Duration(hours: 2)),
          status: RegistrationStatus.confirmed,
        ),
        MatchRegistrationModel(
          id: 'r5',
          matchId: 'm1',
          playerId: 'p5',
          playerName: 'عماد متعب',
          playerPosition: PlayerPosition.forward,
          registeredAt: now.subtract(const Duration(hours: 1)),
          status: RegistrationStatus.confirmed,
        ),
      ],
      waitingList: const [],
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final m2 = MatchModel(
      id: 'm2',
      title: 'كلاسيكو الثلاثاء الحماسي',
      pitchName: 'ملعب سكاي تيرف (Sky Turf BD)',
      location: 'ملعب بارك • 1.2 كم',
      matchDateTime: now.add(const Duration(days: 5, hours: 20)),
      maxPlayers: 10,
      feePerPlayer: 40.0,
      status: MatchStatus.full,
      courtType: 'ملعب خارجي',
      pitchDimensions: '20 × 35 m',
      confirmedPlayers: List.generate(
        10,
        (i) => MatchRegistrationModel(
          id: 'cr_$i',
          matchId: 'm2',
          playerId: 'p_conf_$i',
          playerName: 'لاعب أساسي #${i + 1}',
          playerPosition: PlayerPosition.values[i % 4],
          registeredAt: now.subtract(Duration(hours: 10 - i)),
          status: RegistrationStatus.confirmed,
        ),
      ),
      waitingList: [
        MatchRegistrationModel(
          id: 'w1',
          matchId: 'm2',
          playerId: 'p_wait_1',
          playerName: 'كابتن ماجد',
          playerPosition: PlayerPosition.forward,
          registeredAt: now.subtract(const Duration(minutes: 30)),
          status: RegistrationStatus.waiting,
          queuePosition: 1,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 2)),
    );

    _matches[m1.id] = m1;
    _matches[m2.id] = m2;
  }

  @override
  Future<List<MatchModel>> getMatches({MatchStatus? status}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    var list = _matches.values.toList();
    if (status != null) {
      list = list.where((m) => m.status == status).toList();
    }
    return list;
  }

  @override
  Future<MatchModel> getMatchById(String matchId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final match = _matches[matchId];
    if (match == null) throw const AppException('المباراة غير مسجلة');
    return match;
  }

  @override
  Future<MatchModel> createMatch(MatchModel match) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final id = match.id.isEmpty
        ? 'm_${DateTime.now().millisecondsSinceEpoch}'
        : match.id;
    final created = MatchModel.fromEntity(match.copyWith(id: id));
    _matches[id] = created;
    _streamController.add(created);
    return created;
  }

  @override
  Future<MatchModel> registerPlayer({
    required String matchId,
    required String playerId,
    required String playerName,
    required PlayerPosition position,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final match = _matches[matchId];
    if (match == null) throw const AppException('المباراة غير مسجلة');

    if (match.isPlayerRegistered(playerId)) {
      throw const AppException(
        'اللاعب مسجل بالفعل في هذه المباراة',
        'DUPLICATE_REGISTRATION',
      );
    }

    final now = DateTime.now();
    final regId = 'reg_${now.millisecondsSinceEpoch}';

    List<MatchRegistrationEntity> updatedConfirmed = List.from(
      match.confirmedPlayers,
    );
    List<MatchRegistrationEntity> updatedWaiting = List.from(match.waitingList);
    MatchStatus updatedStatus = match.status;

    if (updatedConfirmed.length < match.maxPlayers) {
      updatedConfirmed.add(
        MatchRegistrationModel(
          id: regId,
          matchId: matchId,
          playerId: playerId,
          playerName: playerName,
          playerPosition: position,
          registeredAt: now,
          status: RegistrationStatus.confirmed,
        ),
      );
      if (updatedConfirmed.length >= match.maxPlayers) {
        updatedStatus = MatchStatus.full;
      }
    } else {
      updatedWaiting.add(
        MatchRegistrationModel(
          id: regId,
          matchId: matchId,
          playerId: playerId,
          playerName: playerName,
          playerPosition: position,
          registeredAt: now,
          status: RegistrationStatus.waiting,
          queuePosition: updatedWaiting.length + 1,
        ),
      );
    }

    final updated = MatchModel.fromEntity(
      match.copyWith(
        confirmedPlayers: updatedConfirmed,
        waitingList: updatedWaiting,
        status: updatedStatus,
      ),
    );

    _matches[matchId] = updated;
    _streamController.add(updated);
    return updated;
  }

  @override
  Future<MatchModel> cancelRegistration({
    required String matchId,
    required String playerId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final match = _matches[matchId];
    if (match == null) throw const AppException('المباراة غير مسجلة');

    List<MatchRegistrationEntity> updatedConfirmed = List.from(
      match.confirmedPlayers,
    );
    List<MatchRegistrationEntity> updatedWaiting = List.from(match.waitingList);

    final wasConfirmed = updatedConfirmed.any((r) => r.playerId == playerId);
    updatedConfirmed.removeWhere((r) => r.playerId == playerId);
    updatedWaiting.removeWhere((r) => r.playerId == playerId);

    // Promote first waiting player if confirmed spot freed
    if (wasConfirmed && updatedWaiting.isNotEmpty) {
      final promoted = updatedWaiting.removeAt(0);
      updatedConfirmed.add(
        promoted.copyWith(
          status: RegistrationStatus.confirmed,
          clearQueuePosition: true,
        ),
      );
    }

    // Re-index waiting list
    final reindexedWaiting = <MatchRegistrationEntity>[];
    for (int i = 0; i < updatedWaiting.length; i++) {
      reindexedWaiting.add(updatedWaiting[i].copyWith(queuePosition: i + 1));
    }

    MatchStatus newStatus = match.status;
    if (updatedConfirmed.length < match.maxPlayers &&
        newStatus == MatchStatus.full) {
      newStatus = MatchStatus.upcoming;
    }

    final updated = MatchModel.fromEntity(
      match.copyWith(
        confirmedPlayers: updatedConfirmed,
        waitingList: reindexedWaiting,
        status: newStatus,
      ),
    );

    _matches[matchId] = updated;
    _streamController.add(updated);
    return updated;
  }

  @override
  Future<MatchResultModel> recordMatchResult(MatchResultModel result) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _results[result.matchId] = result;
    final match = _matches[result.matchId];
    if (match != null) {
      final updatedMatch = match.copyWith(
        status: MatchStatus.completed,
        result: result,
      );
      _matches[result.matchId] = MatchModel.fromEntity(updatedMatch);
      _streamController.add(MatchModel.fromEntity(updatedMatch));
    }
    return result;
  }

  @override
  Future<MatchResultModel?> getMatchResult(String matchId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return _results[matchId] ??
        (_matches[matchId]?.result as MatchResultModel?);
  }

  @override
  Stream<MatchModel?> watchMatch(String matchId) => _streamController.stream;
}

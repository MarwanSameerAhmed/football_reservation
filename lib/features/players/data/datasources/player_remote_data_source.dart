import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/preferred_foot.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/player_skills.dart';
import '../models/player_model.dart';
import '../models/player_skills_model.dart';

abstract class PlayerRemoteDataSource {
  Future<List<PlayerModel>> getPlayers({
    PlayerPosition? positionFilter,
    String? searchQuery,
  });

  Future<PlayerModel> getPlayerById(String id);

  Future<PlayerModel> createPlayer(PlayerModel player);

  Future<PlayerModel> updatePlayer(PlayerModel player);

  Future<PlayerModel> updatePlayerSkills(String playerId, PlayerSkills skills);

  Stream<List<PlayerModel>> get playersStream;
}

class FirebasePlayerRemoteDataSource implements PlayerRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebasePlayerRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _playersCollection =>
      _firestore.collection('players');

  @override
  Future<List<PlayerModel>> getPlayers({
    PlayerPosition? positionFilter,
    String? searchQuery,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _playersCollection;

      if (positionFilter != null) {
        query = query.where('primaryPosition', isEqualTo: positionFilter.name);
      }

      final snapshot = await query.get();
      var players = snapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryClean = searchQuery.toLowerCase().trim();
        players = players
            .where(
              (p) =>
                  p.name.toLowerCase().contains(queryClean) ||
                  (p.nickname != null &&
                      p.nickname!.toLowerCase().contains(queryClean)),
            )
            .toList();
      }

      return players;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerModel> getPlayerById(String id) async {
    try {
      final doc = await _playersCollection.doc(id).get();
      if (!doc.exists) {
        throw const AppException('اللاعب غير موجود');
      }
      return PlayerModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    try {
      final docRef = _playersCollection.doc(
        player.id.isEmpty ? null : player.id,
      );
      final finalPlayer = player.id.isEmpty
          ? PlayerModel.fromEntity(player.copyWith(id: docRef.id))
          : player;
      await docRef.set(finalPlayer.toJson());
      return finalPlayer;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerModel> updatePlayer(PlayerModel player) async {
    try {
      await _playersCollection.doc(player.id).update(player.toJson());
      return player;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerModel> updatePlayerSkills(
    String playerId,
    PlayerSkills skills,
  ) async {
    try {
      final skillsModel = PlayerSkillsModel.fromEntity(skills);
      await _playersCollection.doc(playerId).update({
        'skills': skillsModel.toJson(),
      });
      return await getPlayerById(playerId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<PlayerModel>> get playersStream {
    return _playersCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => PlayerModel.fromFirestore(doc)).toList(),
    );
  }
}

/// Pre-seeded mock data source for immediate offline development and testing.
class MockPlayerRemoteDataSource implements PlayerRemoteDataSource {
  final Map<String, PlayerModel> _players = {};
  final _streamController = StreamController<List<PlayerModel>>.broadcast();
  final Duration delay;

  MockPlayerRemoteDataSource({this.delay = Duration.zero}) {
    _seedDefaultPlayers();
  }

  void _seedDefaultPlayers() {
    final seedList = [
      PlayerModel(
        id: 'p1',
        userId: 'admin_1',
        name: 'مروان سمير',
        nickname: 'المايسترو',
        jerseyNumber: 10,
        primaryPosition: PlayerPosition.midfielder,
        secondaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 88,
          shooting: 85,
          passing: 92,
          defending: 78,
          physical: 84,
        ),
        matchesPlayed: 42,
        goals: 28,
        assists: 34,
        createdAt: DateTime(2025, 1, 10),
      ),
      PlayerModel(
        id: 'p2',
        userId: 'u2',
        name: 'عصام الحضري',
        nickname: 'السد العالي',
        jerseyNumber: 1,
        primaryPosition: PlayerPosition.goalkeeper,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 65,
          shooting: 40,
          passing: 72,
          defending: 90,
          physical: 88,
          goalkeeping: 94,
        ),
        matchesPlayed: 38,
        goals: 0,
        assists: 2,
        createdAt: DateTime(2025, 1, 15),
      ),
      PlayerModel(
        id: 'p3',
        userId: 'u3',
        name: 'وائل جمعة',
        nickname: 'الصخرة',
        jerseyNumber: 4,
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 76,
          shooting: 55,
          passing: 75,
          defending: 94,
          physical: 92,
        ),
        matchesPlayed: 40,
        goals: 5,
        assists: 3,
        createdAt: DateTime(2025, 1, 20),
      ),
      PlayerModel(
        id: 'p4',
        userId: 'u4',
        name: 'محمد بركات',
        nickname: 'الزئبقي',
        jerseyNumber: 8,
        primaryPosition: PlayerPosition.midfielder,
        secondaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 93,
          shooting: 82,
          passing: 88,
          defending: 70,
          physical: 80,
        ),
        matchesPlayed: 35,
        goals: 22,
        assists: 25,
        createdAt: DateTime(2025, 2, 1),
      ),
      PlayerModel(
        id: 'p5',
        userId: 'u5',
        name: 'عماد متعب',
        nickname: 'القناص',
        jerseyNumber: 9,
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.both,
        skills: const PlayerSkills(
          pace: 82,
          shooting: 94,
          passing: 76,
          defending: 60,
          physical: 83,
        ),
        matchesPlayed: 36,
        goals: 41,
        assists: 12,
        createdAt: DateTime(2025, 2, 5),
      ),
      PlayerModel(
        id: 'p6',
        userId: 'u6',
        name: 'سيد معوض',
        nickname: 'الجناح الطائر',
        jerseyNumber: 14,
        primaryPosition: PlayerPosition.defender,
        secondaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 89,
          shooting: 68,
          passing: 84,
          defending: 82,
          physical: 81,
        ),
        matchesPlayed: 30,
        goals: 6,
        assists: 19,
        createdAt: DateTime(2025, 2, 10),
      ),
      PlayerModel(
        id: 'p7',
        userId: 'u7',
        name: 'أحمد فتحي',
        nickname: 'الجوكر',
        primaryPosition: PlayerPosition.defender,
        secondaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 82,
          shooting: 72,
          passing: 80,
          defending: 89,
          physical: 90,
        ),
        matchesPlayed: 38,
        goals: 8,
        assists: 14,
        createdAt: DateTime(2025, 2, 12),
      ),
      PlayerModel(
        id: 'p8',
        userId: 'u8',
        name: 'حسام عاشور',
        nickname: 'المسمار',
        primaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 75,
          shooting: 60,
          passing: 84,
          defending: 91,
          physical: 88,
        ),
        matchesPlayed: 45,
        goals: 2,
        assists: 11,
        createdAt: DateTime(2025, 2, 15),
      ),
      PlayerModel(
        id: 'p9',
        userId: 'u9',
        name: 'محمد أبو تريكة',
        nickname: 'أمير القلوب',
        primaryPosition: PlayerPosition.midfielder,
        secondaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 84,
          shooting: 92,
          passing: 96,
          defending: 62,
          physical: 78,
        ),
        matchesPlayed: 48,
        goals: 38,
        assists: 42,
        createdAt: DateTime(2025, 2, 18),
      ),
      PlayerModel(
        id: 'p10',
        userId: 'u10',
        name: 'محمد صلاح',
        nickname: 'فخر العرب',
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 96,
          shooting: 93,
          passing: 86,
          defending: 48,
          physical: 79,
        ),
        matchesPlayed: 50,
        goals: 52,
        assists: 31,
        createdAt: DateTime(2025, 2, 20),
      ),
      PlayerModel(
        id: 'p11',
        userId: 'u11',
        name: 'طارق حامد',
        nickname: 'قلب الأسد',
        primaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 78,
          shooting: 65,
          passing: 81,
          defending: 92,
          physical: 91,
        ),
        matchesPlayed: 39,
        goals: 4,
        assists: 8,
        createdAt: DateTime(2025, 2, 22),
      ),
      PlayerModel(
        id: 'p12',
        userId: 'u12',
        name: 'علي معلول',
        nickname: 'ملك الحلول',
        primaryPosition: PlayerPosition.defender,
        secondaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 86,
          shooting: 80,
          passing: 90,
          defending: 79,
          physical: 77,
        ),
        matchesPlayed: 37,
        goals: 14,
        assists: 26,
        createdAt: DateTime(2025, 2, 25),
      ),
      PlayerModel(
        id: 'p13',
        userId: 'u13',
        name: 'عمر مرموش',
        nickname: 'الصاروخ',
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 94,
          shooting: 89,
          passing: 82,
          defending: 45,
          physical: 80,
        ),
        matchesPlayed: 29,
        goals: 24,
        assists: 15,
        createdAt: DateTime(2025, 3, 1),
      ),
      PlayerModel(
        id: 'p14',
        userId: 'u14',
        name: 'تريزيجيه',
        nickname: 'المحارب',
        primaryPosition: PlayerPosition.midfielder,
        secondaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 89,
          shooting: 84,
          passing: 83,
          defending: 68,
          physical: 82,
        ),
        matchesPlayed: 33,
        goals: 18,
        assists: 16,
        createdAt: DateTime(2025, 3, 3),
      ),
      PlayerModel(
        id: 'p15',
        userId: 'u15',
        name: 'أحمد حجازي',
        nickname: 'برج المراقبة',
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 73,
          shooting: 58,
          passing: 74,
          defending: 93,
          physical: 94,
        ),
        matchesPlayed: 36,
        goals: 7,
        assists: 4,
        createdAt: DateTime(2025, 3, 5),
      ),
      PlayerModel(
        id: 'p16',
        userId: 'u16',
        name: 'مصطفى محمد',
        nickname: 'الأناكوندا',
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 84,
          shooting: 91,
          passing: 73,
          defending: 55,
          physical: 90,
        ),
        matchesPlayed: 31,
        goals: 27,
        assists: 9,
        createdAt: DateTime(2025, 3, 8),
      ),
      PlayerModel(
        id: 'p17',
        userId: 'u17',
        name: 'إمام عاشور',
        nickname: 'دينامو الوسط',
        primaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 87,
          shooting: 88,
          passing: 87,
          defending: 77,
          physical: 85,
        ),
        matchesPlayed: 35,
        goals: 21,
        assists: 22,
        createdAt: DateTime(2025, 3, 10),
      ),
      PlayerModel(
        id: 'p18',
        userId: 'u18',
        name: 'محمد الشناوي',
        nickname: 'الأخطبوط',
        primaryPosition: PlayerPosition.goalkeeper,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 62,
          shooting: 35,
          passing: 74,
          defending: 89,
          physical: 91,
          goalkeeping: 93,
        ),
        matchesPlayed: 44,
        goals: 0,
        assists: 3,
        createdAt: DateTime(2025, 3, 12),
      ),
    ];

    for (final p in seedList) {
      _players[p.id] = p;
    }
  }

  @override
  Future<List<PlayerModel>> getPlayers({
    PlayerPosition? positionFilter,
    String? searchQuery,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    var list = _players.values.toList();

    if (positionFilter != null) {
      list = list.where((p) => p.primaryPosition == positionFilter).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.nickname != null && p.nickname!.toLowerCase().contains(q)),
          )
          .toList();
    }

    return list;
  }

  @override
  Future<PlayerModel> getPlayerById(String id) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final player = _players[id];
    if (player == null) {
      throw const AppException('اللاعب غير مسجل');
    }
    return player;
  }

  @override
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final id = player.id.isEmpty
        ? 'p_${DateTime.now().millisecondsSinceEpoch}'
        : player.id;
    final created = PlayerModel.fromEntity(player.copyWith(id: id));
    _players[id] = created;
    _streamController.add(_players.values.toList());
    return created;
  }

  @override
  Future<PlayerModel> updatePlayer(PlayerModel player) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _players[player.id] = player;
    _streamController.add(_players.values.toList());
    return player;
  }

  @override
  Future<PlayerModel> updatePlayerSkills(
    String playerId,
    PlayerSkills skills,
  ) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final player = _players[playerId];
    if (player == null) throw const AppException('اللاعب غير موجود');

    final updated = PlayerModel.fromEntity(player.copyWith(skills: skills));
    _players[playerId] = updated;
    _streamController.add(_players.values.toList());
    return updated;
  }

  @override
  Stream<List<PlayerModel>> get playersStream => _streamController.stream;
}

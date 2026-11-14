import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/preferred_foot.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/character_avatar_helper.dart';
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

  MockPlayerRemoteDataSource({
    this.delay = Duration.zero,
    bool seedDefault = true,
  }) {
    if (seedDefault) {
      _seedDefaultPlayers();
    }
  }

  void clearAll() {
    _players.clear();
    _streamController.add([]);
  }

  void _seedDefaultPlayers() {
    final seedList = [
      PlayerModel(
        id: 'p1',
        userId: 'admin_1',
        name: 'مروان سمير',
        nickname: 'المايسترو',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('MarwanSameer'),
        jerseyNumber: 10,
        primaryPosition: PlayerPosition.midfielder,
        secondaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 82,
          shooting: 84,
          passing: 89,
          defending: 75,
          physical: 80,
        ),
        matchesPlayed: 24,
        goals: 12,
        assists: 16,
        createdAt: DateTime(2025, 1, 10),
      ),
      PlayerModel(
        id: 'p2',
        userId: 'u2',
        name: 'فهد الدوسري',
        nickname: 'الأخطبوط',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('FahadAlDosari'),
        jerseyNumber: 1,
        primaryPosition: PlayerPosition.goalkeeper,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 72,
          shooting: 55,
          passing: 76,
          defending: 88,
          physical: 86,
          goalkeeping: 90,
        ),
        matchesPlayed: 20,
        goals: 0,
        assists: 1,
        createdAt: DateTime(2025, 1, 15),
      ),
      PlayerModel(
        id: 'p3',
        userId: 'u3',
        name: 'عمر الشهري',
        nickname: 'الصخرة',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('OmarAlShehri'),
        jerseyNumber: 4,
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 78,
          shooting: 58,
          passing: 75,
          defending: 88,
          physical: 86,
        ),
        matchesPlayed: 22,
        goals: 3,
        assists: 2,
        createdAt: DateTime(2025, 1, 20),
      ),
      PlayerModel(
        id: 'p4',
        userId: 'u4',
        name: 'سفيان العلي',
        nickname: 'القناص',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SufyanAlAli'),
        jerseyNumber: 9,
        primaryPosition: PlayerPosition.forward,
        secondaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 86,
          shooting: 89,
          passing: 78,
          defending: 55,
          physical: 82,
        ),
        matchesPlayed: 21,
        goals: 23,
        assists: 6,
        createdAt: DateTime(2025, 2, 1),
      ),
      PlayerModel(
        id: 'p5',
        userId: 'u5',
        name: 'طارق الحربي',
        nickname: 'المحرك',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('TarekAlHarbi'),
        jerseyNumber: 8,
        primaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 80,
          shooting: 76,
          passing: 84,
          defending: 80,
          physical: 80,
        ),
        matchesPlayed: 23,
        goals: 8,
        assists: 14,
        createdAt: DateTime(2025, 2, 5),
      ),
      PlayerModel(
        id: 'p6',
        userId: 'u6',
        name: 'سالم العنزي',
        nickname: 'السهم',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SalimAlAnazi'),
        jerseyNumber: 11,
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 89,
          shooting: 84,
          passing: 76,
          defending: 52,
          physical: 79,
        ),
        matchesPlayed: 19,
        goals: 17,
        assists: 8,
        createdAt: DateTime(2025, 2, 10),
      ),
      PlayerModel(
        id: 'p7',
        userId: 'u7',
        name: 'خالد القحطاني',
        nickname: 'السد',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('KhaledAlQahtani'),
        jerseyNumber: 3,
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 76,
          shooting: 54,
          passing: 74,
          defending: 87,
          physical: 84,
        ),
        matchesPlayed: 18,
        goals: 2,
        assists: 3,
        createdAt: DateTime(2025, 2, 12),
      ),
      PlayerModel(
        id: 'p8',
        userId: 'u8',
        name: 'عبد الله السالم',
        nickname: 'الأمين',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('AbdallahAlSalem'),
        jerseyNumber: 22,
        primaryPosition: PlayerPosition.goalkeeper,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 70,
          shooting: 50,
          passing: 74,
          defending: 85,
          physical: 84,
          goalkeeping: 86,
        ),
        matchesPlayed: 16,
        goals: 0,
        assists: 2,
        createdAt: DateTime(2025, 2, 15),
      ),
      PlayerModel(
        id: 'p9',
        userId: 'u9',
        name: 'فيصل الغامدي',
        nickname: 'المهندس',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('FaisalAlGhamdi'),
        jerseyNumber: 6,
        primaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 81,
          shooting: 78,
          passing: 87,
          defending: 75,
          physical: 79,
        ),
        matchesPlayed: 20,
        goals: 9,
        assists: 15,
        createdAt: DateTime(2025, 2, 18),
      ),
      PlayerModel(
        id: 'p10',
        userId: 'u10',
        name: 'ريان المطيري',
        nickname: 'البرق',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('RayanAlMutairi'),
        jerseyNumber: 7,
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 88,
          shooting: 83,
          passing: 76,
          defending: 54,
          physical: 74,
        ),
        matchesPlayed: 17,
        goals: 14,
        assists: 10,
        createdAt: DateTime(2025, 2, 20),
      ),
      PlayerModel(
        id: 'p11',
        userId: 'u11',
        name: 'ياسر العتيبي',
        nickname: 'الفولاذ',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('YasserAlOtaibi'),
        jerseyNumber: 5,
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 77,
          shooting: 56,
          passing: 72,
          defending: 86,
          physical: 84,
        ),
        matchesPlayed: 18,
        goals: 1,
        assists: 2,
        createdAt: DateTime(2025, 2, 22),
      ),
      PlayerModel(
        id: 'p12',
        userId: 'u12',
        name: 'سعود الشمري',
        nickname: 'الجوكر',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SaudAlShammari'),
        jerseyNumber: 14,
        primaryPosition: PlayerPosition.midfielder,
        secondaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.both,
        skills: const PlayerSkills(
          pace: 80,
          shooting: 77,
          passing: 83,
          defending: 78,
          physical: 82,
        ),
        matchesPlayed: 21,
        goals: 7,
        assists: 11,
        createdAt: DateTime(2025, 2, 25),
      ),
      PlayerModel(
        id: 'p13',
        userId: 'u13',
        name: 'بدر السعد',
        nickname: 'الهدّاف',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('BadrAlSaad'),
        jerseyNumber: 17,
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 84,
          shooting: 87,
          passing: 74,
          defending: 50,
          physical: 80,
        ),
        matchesPlayed: 16,
        goals: 18,
        assists: 5,
        createdAt: DateTime(2025, 3, 1),
      ),
      PlayerModel(
        id: 'p14',
        userId: 'u14',
        name: 'نايف الحارثي',
        nickname: 'الجدار',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('NaifAlHarthi'),
        jerseyNumber: 2,
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 79,
          shooting: 60,
          passing: 75,
          defending: 85,
          physical: 81,
        ),
        matchesPlayed: 17,
        goals: 4,
        assists: 5,
        createdAt: DateTime(2025, 3, 3),
      ),
      PlayerModel(
        id: 'p15',
        userId: 'u15',
        name: 'عبد الرحمن الزهراني',
        nickname: 'الفنان',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('AbdelrahmanAlZahrani'),
        jerseyNumber: 18,
        primaryPosition: PlayerPosition.midfielder,
        preferredFoot: PreferredFoot.left,
        skills: const PlayerSkills(
          pace: 82,
          shooting: 79,
          passing: 86,
          defending: 70,
          physical: 78,
        ),
        matchesPlayed: 19,
        goals: 10,
        assists: 13,
        createdAt: DateTime(2025, 3, 5),
      ),
      PlayerModel(
        id: 'p16',
        userId: 'u16',
        name: 'وليد المالكي',
        nickname: 'الصقر',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('WaleedAlMalki'),
        jerseyNumber: 16,
        primaryPosition: PlayerPosition.goalkeeper,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 68,
          shooting: 52,
          passing: 72,
          defending: 84,
          physical: 84,
          goalkeeping: 85,
        ),
        matchesPlayed: 15,
        goals: 0,
        assists: 0,
        createdAt: DateTime(2025, 3, 8),
      ),
      PlayerModel(
        id: 'p17',
        userId: 'u17',
        name: 'سامي الخالدي',
        nickname: 'المقاتل',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SamiAlKhaldi'),
        jerseyNumber: 20,
        primaryPosition: PlayerPosition.defender,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 78,
          shooting: 55,
          passing: 73,
          defending: 85,
          physical: 84,
        ),
        matchesPlayed: 19,
        goals: 3,
        assists: 3,
        createdAt: DateTime(2025, 3, 10),
      ),
      PlayerModel(
        id: 'p18',
        userId: 'u18',
        name: 'عادل السلمي',
        nickname: 'المنقذ',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('AdelAlSulami'),
        jerseyNumber: 19,
        primaryPosition: PlayerPosition.forward,
        preferredFoot: PreferredFoot.right,
        skills: const PlayerSkills(
          pace: 85,
          shooting: 84,
          passing: 75,
          defending: 53,
          physical: 78,
        ),
        matchesPlayed: 15,
        goals: 12,
        assists: 6,
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

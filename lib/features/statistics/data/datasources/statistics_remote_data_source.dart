import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/character_avatar_helper.dart';
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
      PlayerStatsModel(
        playerId: 'p1',
        playerName: 'مروان سمير',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('MarwanSameer'),
        position: PlayerPosition.midfielder,
        matchesPlayed: 24,
        goals: 12,
        assists: 16,
        cleanSheets: 3,
        motmAwards: 6,
        wins: 15,
        draws: 4,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p2',
        playerName: 'فهد الدوسري',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('FahadAlDosari'),
        position: PlayerPosition.goalkeeper,
        matchesPlayed: 20,
        goals: 0,
        assists: 1,
        cleanSheets: 9,
        motmAwards: 4,
        wins: 13,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p3',
        playerName: 'عمر الشهري',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('OmarAlShehri'),
        position: PlayerPosition.defender,
        matchesPlayed: 22,
        goals: 3,
        assists: 2,
        cleanSheets: 7,
        motmAwards: 2,
        wins: 12,
        draws: 4,
        losses: 6,
      ),
      PlayerStatsModel(
        playerId: 'p4',
        playerName: 'سفيان العلي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SufyanAlAli'),
        position: PlayerPosition.forward,
        matchesPlayed: 21,
        goals: 23,
        assists: 6,
        cleanSheets: 0,
        motmAwards: 5,
        wins: 14,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p5',
        playerName: 'طارق الحربي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('TarekAlHarbi'),
        position: PlayerPosition.midfielder,
        matchesPlayed: 23,
        goals: 8,
        assists: 14,
        cleanSheets: 4,
        motmAwards: 3,
        wins: 13,
        draws: 5,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p6',
        playerName: 'سالم العنزي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SalimAlAnazi'),
        position: PlayerPosition.forward,
        matchesPlayed: 19,
        goals: 17,
        assists: 8,
        cleanSheets: 0,
        motmAwards: 4,
        wins: 11,
        draws: 3,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p7',
        playerName: 'خالد القحطاني',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('KhaledAlQahtani'),
        position: PlayerPosition.defender,
        matchesPlayed: 18,
        goals: 2,
        assists: 3,
        cleanSheets: 6,
        motmAwards: 1,
        wins: 10,
        draws: 3,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p8',
        playerName: 'عبد الله السالم',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('AbdallahAlSalem'),
        position: PlayerPosition.goalkeeper,
        matchesPlayed: 16,
        goals: 0,
        assists: 2,
        cleanSheets: 6,
        motmAwards: 2,
        wins: 9,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p9',
        playerName: 'فيصل الغامدي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('FaisalAlGhamdi'),
        position: PlayerPosition.midfielder,
        matchesPlayed: 20,
        goals: 9,
        assists: 15,
        cleanSheets: 3,
        motmAwards: 3,
        wins: 12,
        draws: 4,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p10',
        playerName: 'ريان المطيري',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('RayanAlMutairi'),
        position: PlayerPosition.forward,
        matchesPlayed: 17,
        goals: 14,
        assists: 10,
        cleanSheets: 0,
        motmAwards: 3,
        wins: 10,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p11',
        playerName: 'ياسر العتيبي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('YasserAlOtaibi'),
        position: PlayerPosition.defender,
        matchesPlayed: 18,
        goals: 1,
        assists: 2,
        cleanSheets: 5,
        motmAwards: 1,
        wins: 9,
        draws: 4,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p12',
        playerName: 'سعود الشمري',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SaudAlShammari'),
        position: PlayerPosition.midfielder,
        matchesPlayed: 21,
        goals: 7,
        assists: 11,
        cleanSheets: 4,
        motmAwards: 2,
        wins: 11,
        draws: 4,
        losses: 6,
      ),
      PlayerStatsModel(
        playerId: 'p13',
        playerName: 'بدر السعد',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('BadrAlSaad'),
        position: PlayerPosition.forward,
        matchesPlayed: 16,
        goals: 18,
        assists: 5,
        cleanSheets: 0,
        motmAwards: 3,
        wins: 9,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p14',
        playerName: 'نايف الحارثي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('NaifAlHarthi'),
        position: PlayerPosition.defender,
        matchesPlayed: 17,
        goals: 4,
        assists: 5,
        cleanSheets: 5,
        motmAwards: 2,
        wins: 10,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p15',
        playerName: 'عبد الرحمن الزهراني',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('AbdelrahmanAlZahrani'),
        position: PlayerPosition.midfielder,
        matchesPlayed: 19,
        goals: 10,
        assists: 13,
        cleanSheets: 2,
        motmAwards: 3,
        wins: 11,
        draws: 3,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p16',
        playerName: 'وليد المالكي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('WaleedAlMalki'),
        position: PlayerPosition.goalkeeper,
        matchesPlayed: 15,
        goals: 0,
        assists: 0,
        cleanSheets: 5,
        motmAwards: 1,
        wins: 8,
        draws: 3,
        losses: 4,
      ),
      PlayerStatsModel(
        playerId: 'p17',
        playerName: 'سامي الخالدي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('SamiAlKhaldi'),
        position: PlayerPosition.defender,
        matchesPlayed: 19,
        goals: 3,
        assists: 3,
        cleanSheets: 6,
        motmAwards: 2,
        wins: 10,
        draws: 4,
        losses: 5,
      ),
      PlayerStatsModel(
        playerId: 'p18',
        playerName: 'عادل السلمي',
        photoUrl: CharacterAvatarHelper.getCharacterUrl('AdelAlSulami'),
        position: PlayerPosition.forward,
        matchesPlayed: 15,
        goals: 12,
        assists: 6,
        cleanSheets: 0,
        motmAwards: 2,
        wins: 8,
        draws: 3,
        losses: 4,
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

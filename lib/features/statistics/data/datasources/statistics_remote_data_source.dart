import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/character_avatar_helper.dart';
import '../../../matches/data/datasources/match_remote_data_source.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../players/data/datasources/player_remote_data_source.dart';
import '../models/group_leaderboard_model.dart';
import '../models/player_stats_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<GroupLeaderboardModel> getGroupLeaderboards();

  Future<PlayerStatsModel> getPlayerStats(String playerId);
}

class _MutablePlayerAccumulator {
  final String playerId;
  final String playerName;
  final String? photoUrl;
  final PlayerPosition position;
  int matchesPlayed = 0;
  int goals = 0;
  int assists = 0;
  int cleanSheets = 0;
  int motmAwards = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;

  _MutablePlayerAccumulator({
    required this.playerId,
    required this.playerName,
    this.photoUrl,
    this.position = PlayerPosition.midfielder,
  });

  PlayerStatsModel toModel() => PlayerStatsModel(
    playerId: playerId,
    playerName: playerName,
    photoUrl: photoUrl,
    position: position,
    matchesPlayed: matchesPlayed,
    goals: goals,
    assists: assists,
    cleanSheets: cleanSheets,
    motmAwards: motmAwards,
    wins: wins,
    draws: draws,
    losses: losses,
  );
}

GroupLeaderboardModel _buildLeaderboardFromStats(
  List<PlayerStatsModel> all, {
  required int totalMatches,
  int? totalGoalsOverride,
}) {
  final topScorers = List<PlayerStatsModel>.from(all)
    ..sort((a, b) => b.goals.compareTo(a.goals));
  final topAssisters = List<PlayerStatsModel>.from(all)
    ..sort((a, b) => b.assists.compareTo(a.assists));
  final topCleanSheets = List<PlayerStatsModel>.from(all)
    ..sort((a, b) => b.cleanSheets.compareTo(a.cleanSheets));
  final topMotm = List<PlayerStatsModel>.from(all)
    ..sort((a, b) => b.motmAwards.compareTo(a.motmAwards));

  final totalGoals =
      totalGoalsOverride ?? all.fold<int>(0, (acc, p) => acc + p.goals);

  return GroupLeaderboardModel(
    topScorers: topScorers,
    topAssisters: topAssisters,
    topCleanSheets: topCleanSheets,
    topMotm: topMotm,
    allPlayers: all,
    totalMatches: totalMatches,
    totalGoals: totalGoals,
  );
}

/// Computes live group statistics and leaderboards directly from recorded match
/// results and the current player roster so both Firestore and offline modes stay accurate.
Future<GroupLeaderboardModel> _computeLeaderboardFromSources({
  required MatchRemoteDataSource matchDataSource,
  required PlayerRemoteDataSource playerDataSource,
}) async {
  final matches = await matchDataSource.getMatches();
  final players = await playerDataSource.getPlayers();
  final completedMatches = matches
      .where((m) => m.result != null || m.status == MatchStatus.completed)
      .toList();

  if (completedMatches.isEmpty) {
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

  final byKey = <String, _MutablePlayerAccumulator>{};
  final nameToKey = <String, String>{};

  void registerPlayer({
    required String id,
    required String name,
    String? photoUrl,
    PlayerPosition position = PlayerPosition.midfielder,
  }) {
    final normalizedName = name.trim().toLowerCase();
    if (normalizedName.isEmpty) return;
    final key = nameToKey[normalizedName] ?? id;
    nameToKey[normalizedName] = key;
    byKey.putIfAbsent(
      key,
      () => _MutablePlayerAccumulator(
        playerId: id,
        playerName: name.trim(),
        photoUrl:
            photoUrl ?? CharacterAvatarHelper.getCharacterUrl(name.trim()),
        position: position,
      ),
    );
  }

  _MutablePlayerAccumulator resolveOrCreate({
    String? id,
    required String name,
    String? photoUrl,
    PlayerPosition position = PlayerPosition.midfielder,
  }) {
    final trimmed = name.trim();
    final normalizedName = trimmed.toLowerCase();
    if (nameToKey.containsKey(normalizedName)) {
      return byKey[nameToKey[normalizedName]!]!;
    }
    if (id != null && byKey.containsKey(id)) {
      return byKey[id]!;
    }
    final assignedId = (id != null && id.isNotEmpty)
        ? id
        : 'stats_${trimmed.hashCode}';
    registerPlayer(
      id: assignedId,
      name: trimmed,
      photoUrl: photoUrl,
      position: position,
    );
    return byKey[nameToKey[normalizedName]!]!;
  }

  for (final p in players) {
    registerPlayer(
      id: p.id,
      name: p.name,
      photoUrl: p.photoUrl,
      position: p.primaryPosition,
    );
  }

  var totalGoals = 0;
  for (final MatchEntity match in completedMatches) {
    final seenInMatch = <String>{};
    for (final reg in match.confirmedPlayers) {
      final acc = resolveOrCreate(
        id: reg.playerId,
        name: reg.playerName,
        position: reg.playerPosition,
      );
      if (seenInMatch.add(acc.playerId)) {
        acc.matchesPlayed++;
      }
    }

    final result = match.result;
    if (result == null) continue;

    for (final goal in result.goals) {
      totalGoals++;
      if (goal.scorerName.trim().isNotEmpty) {
        final scorer = resolveOrCreate(
          id: goal.scorerPlayerId,
          name: goal.scorerName,
        );
        scorer.goals++;
        if (seenInMatch.add(scorer.playerId)) {
          scorer.matchesPlayed++;
        }
      }
      final assistName = goal.assistPlayerName?.trim();
      if (assistName != null && assistName.isNotEmpty) {
        final assister = resolveOrCreate(name: assistName);
        assister.assists++;
        if (seenInMatch.add(assister.playerId)) {
          assister.matchesPlayed++;
        }
      }
    }

    final motmName = result.manOfTheMatchName?.trim();
    if (motmName != null && motmName.isNotEmpty) {
      final motm = resolveOrCreate(name: motmName);
      motm.motmAwards++;
      if (seenInMatch.add(motm.playerId)) {
        motm.matchesPlayed++;
      }
    }
  }

  final activeStats = byKey.values
      .where(
        (a) =>
            a.matchesPlayed > 0 ||
            a.goals > 0 ||
            a.assists > 0 ||
            a.motmAwards > 0,
      )
      .map((a) => a.toModel())
      .toList();

  if (activeStats.isEmpty) {
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

  return _buildLeaderboardFromStats(
    activeStats,
    totalMatches: completedMatches.length,
    totalGoalsOverride: totalGoals,
  );
}

class FirebaseStatisticsRemoteDataSource implements StatisticsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final MatchRemoteDataSource? _matchDataSource;
  final PlayerRemoteDataSource? _playerDataSource;

  FirebaseStatisticsRemoteDataSource({
    FirebaseFirestore? firestore,
    MatchRemoteDataSource? matchDataSource,
    PlayerRemoteDataSource? playerDataSource,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _matchDataSource = matchDataSource,
       _playerDataSource = playerDataSource;

  @override
  Future<GroupLeaderboardModel> getGroupLeaderboards() async {
    try {
      if (_matchDataSource != null && _playerDataSource != null) {
        final computed = await _computeLeaderboardFromSources(
          matchDataSource: _matchDataSource,
          playerDataSource: _playerDataSource,
        );
        if (computed.allPlayers.isNotEmpty) {
          return computed;
        }
      }

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
      if (_matchDataSource != null && _playerDataSource != null) {
        final computed = await _computeLeaderboardFromSources(
          matchDataSource: _matchDataSource,
          playerDataSource: _playerDataSource,
        );
        final match = computed.allPlayers
            .where((p) => p.playerId == playerId)
            .firstOrNull;
        if (match != null) return PlayerStatsModel.fromEntity(match);
      }

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
  final MatchRemoteDataSource? _matchDataSource;
  final PlayerRemoteDataSource? _playerDataSource;
  final Duration delay;

  MockStatisticsRemoteDataSource({
    this.delay = Duration.zero,
    bool seedDefault = true,
    MatchRemoteDataSource? matchDataSource,
    PlayerRemoteDataSource? playerDataSource,
  }) : _matchDataSource = matchDataSource,
       _playerDataSource = playerDataSource {
    if (seedDefault) {
      _seedDefaultStats();
    }
  }

  void clearAll() {
    _playerStats.clear();
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

    if (_playerStats.isEmpty &&
        _matchDataSource != null &&
        _playerDataSource != null) {
      return _computeLeaderboardFromSources(
        matchDataSource: _matchDataSource,
        playerDataSource: _playerDataSource,
      );
    }

    return _buildLeaderboardFromStats(
      _playerStats.values.toList(),
      totalMatches: 24,
    );
  }

  @override
  Future<PlayerStatsModel> getPlayerStats(String playerId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final stats = _playerStats[playerId];
    if (stats != null) return stats;

    if (_matchDataSource != null && _playerDataSource != null) {
      final computed = await _computeLeaderboardFromSources(
        matchDataSource: _matchDataSource,
        playerDataSource: _playerDataSource,
      );
      final match = computed.allPlayers
          .where((p) => p.playerId == playerId)
          .firstOrNull;
      if (match != null) return PlayerStatsModel.fromEntity(match);
    }

    throw NotFoundException('إحصائيات اللاعب غير متوفرة');
  }
}

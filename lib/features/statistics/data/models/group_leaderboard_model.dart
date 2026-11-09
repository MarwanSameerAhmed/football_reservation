import '../../domain/entities/group_leaderboard_entity.dart';
import 'player_stats_model.dart';

class GroupLeaderboardModel extends GroupLeaderboardEntity {
  const GroupLeaderboardModel({
    required super.topScorers,
    required super.topAssisters,
    required super.topCleanSheets,
    required super.topMotm,
    required super.allPlayers,
    required super.totalMatches,
    required super.totalGoals,
  });

  factory GroupLeaderboardModel.fromEntity(GroupLeaderboardEntity entity) {
    return GroupLeaderboardModel(
      topScorers: entity.topScorers
          .map((p) => PlayerStatsModel.fromEntity(p))
          .toList(),
      topAssisters: entity.topAssisters
          .map((p) => PlayerStatsModel.fromEntity(p))
          .toList(),
      topCleanSheets: entity.topCleanSheets
          .map((p) => PlayerStatsModel.fromEntity(p))
          .toList(),
      topMotm: entity.topMotm
          .map((p) => PlayerStatsModel.fromEntity(p))
          .toList(),
      allPlayers: entity.allPlayers
          .map((p) => PlayerStatsModel.fromEntity(p))
          .toList(),
      totalMatches: entity.totalMatches,
      totalGoals: entity.totalGoals,
    );
  }

  factory GroupLeaderboardModel.fromJson(Map<String, dynamic> json) {
    List<PlayerStatsModel> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map(
            (item) => PlayerStatsModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return GroupLeaderboardModel(
      topScorers: parseList('topScorers'),
      topAssisters: parseList('topAssisters'),
      topCleanSheets: parseList('topCleanSheets'),
      topMotm: parseList('topMotm'),
      allPlayers: parseList('allPlayers'),
      totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
      totalGoals: (json['totalGoals'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topScorers': topScorers
          .map((p) => PlayerStatsModel.fromEntity(p).toJson())
          .toList(),
      'topAssisters': topAssisters
          .map((p) => PlayerStatsModel.fromEntity(p).toJson())
          .toList(),
      'topCleanSheets': topCleanSheets
          .map((p) => PlayerStatsModel.fromEntity(p).toJson())
          .toList(),
      'topMotm': topMotm
          .map((p) => PlayerStatsModel.fromEntity(p).toJson())
          .toList(),
      'allPlayers': allPlayers
          .map((p) => PlayerStatsModel.fromEntity(p).toJson())
          .toList(),
      'totalMatches': totalMatches,
      'totalGoals': totalGoals,
    };
  }
}

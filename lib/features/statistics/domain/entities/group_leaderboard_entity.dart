import 'package:equatable/equatable.dart';
import 'player_stats_entity.dart';

/// Pure domain entity holding comprehensive group leaderboards and totals.
class GroupLeaderboardEntity extends Equatable {
  final List<PlayerStatsEntity> topScorers;
  final List<PlayerStatsEntity> topAssisters;
  final List<PlayerStatsEntity> topCleanSheets;
  final List<PlayerStatsEntity> topMotm;
  final List<PlayerStatsEntity> allPlayers;
  final int totalMatches;
  final int totalGoals;

  const GroupLeaderboardEntity({
    required this.topScorers,
    required this.topAssisters,
    required this.topCleanSheets,
    required this.topMotm,
    required this.allPlayers,
    required this.totalMatches,
    required this.totalGoals,
  });

  double get averageGoalsPerMatch {
    if (totalMatches == 0) return 0.0;
    final avg = totalGoals / totalMatches;
    return (avg * 10).round() / 10;
  }

  @override
  List<Object?> get props => [
    topScorers,
    topAssisters,
    topCleanSheets,
    topMotm,
    allPlayers,
    totalMatches,
    totalGoals,
  ];
}

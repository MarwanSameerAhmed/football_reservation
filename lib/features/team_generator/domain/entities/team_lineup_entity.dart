import 'package:equatable/equatable.dart';
import 'generated_team_entity.dart';

class TeamLineupEntity extends Equatable {
  final String id;
  final String matchId;
  final List<GeneratedTeamEntity> teams;
  final DateTime generatedAt;
  final bool isFinalized;

  const TeamLineupEntity({
    required this.id,
    required this.matchId,
    required this.teams,
    required this.generatedAt,
    this.isFinalized = false,
  });

  /// Backwards compatibility getters
  GeneratedTeamEntity get teamA => teams.isNotEmpty
      ? teams[0]
      : const GeneratedTeamEntity(
          id: 'team_a',
          name: 'الفريق الأول',
          bibColor: 'الأخضر العشبي',
          players: [],
        );

  GeneratedTeamEntity get teamB => teams.length > 1
      ? teams[1]
      : const GeneratedTeamEntity(
          id: 'team_b',
          name: 'الفريق الثاني',
          bibColor: 'الأبيض الناصع',
          players: [],
        );

  GeneratedTeamEntity? get teamC => teams.length > 2 ? teams[2] : null;

  /// Absolute maximum difference in overall score between any two teams.
  int get scoreDifference {
    if (teams.length < 2) return 0;
    final scores = teams.map((t) => t.totalScore).toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    return maxScore - minScore;
  }

  /// Absolute maximum difference in average stars rating (e.g. 0.1 ★).
  double get ratingDifference {
    if (teams.length < 2) return 0.0;
    final ratings = teams.map((t) => t.averageRating).toList();
    final maxRating = ratings.reduce((a, b) => a > b ? a : b);
    final minRating = ratings.reduce((a, b) => a < b ? a : b);
    return ((maxRating - minRating).abs() * 10).round() / 10;
  }

  /// Balance index from 0% to 100% (where 100% means perfectly equal).
  int get balancePercentage {
    if (teams.length < 2) return 100;
    final maxScore = teams
        .map((t) => t.totalScore)
        .reduce((a, b) => a > b ? a : b);
    if (maxScore == 0) return 100;
    final ratio = 1.0 - (scoreDifference / maxScore);
    return (ratio * 100).round().clamp(0, 100);
  }

  TeamLineupEntity copyWith({
    String? id,
    String? matchId,
    List<GeneratedTeamEntity>? teams,
    GeneratedTeamEntity? teamA,
    GeneratedTeamEntity? teamB,
    DateTime? generatedAt,
    bool? isFinalized,
  }) {
    List<GeneratedTeamEntity> newTeams = teams != null
        ? List.from(teams)
        : List.from(this.teams);

    if (teams == null && (teamA != null || teamB != null)) {
      if (newTeams.isEmpty) {
        if (teamA != null) newTeams.add(teamA);
        if (teamB != null) newTeams.add(teamB);
      } else {
        if (teamA != null && newTeams.isNotEmpty) newTeams[0] = teamA;
        if (teamB != null && newTeams.length > 1) newTeams[1] = teamB;
      }
    }

    return TeamLineupEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      teams: newTeams,
      generatedAt: generatedAt ?? this.generatedAt,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }

  @override
  List<Object?> get props => [id, matchId, teams, generatedAt, isFinalized];
}

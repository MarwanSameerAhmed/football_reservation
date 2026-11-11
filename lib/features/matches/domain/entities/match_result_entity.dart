import 'package:equatable/equatable.dart';
import 'card_event_entity.dart';
import 'goal_event_entity.dart';

/// Pure domain entity representing the official score and match result.
class MatchResultEntity extends Equatable {
  final String id;
  final String matchId;
  final int teamAScore;
  final int teamBScore;
  final int? teamCScore;
  final String teamAName;
  final String teamBName;
  final String? teamCName;
  final List<GoalEventEntity> goals;
  final List<CardEventEntity> cards;
  final String? manOfTheMatchPlayerId;
  final String? manOfTheMatchName;
  final bool isLocked;
  final DateTime recordedAt;
  final String? notes;

  const MatchResultEntity({
    required this.id,
    required this.matchId,
    required this.teamAScore,
    required this.teamBScore,
    this.teamCScore,
    this.teamAName = 'الفريق الأول (الأخضر)',
    this.teamBName = 'الفريق الثاني (الأبيض)',
    this.teamCName = 'الفريق الثالث (الأسود)',
    this.goals = const [],
    this.cards = const [],
    this.manOfTheMatchPlayerId,
    this.manOfTheMatchName,
    this.isLocked = false,
    required this.recordedAt,
    this.notes,
  });

  bool get isDraw => teamAScore == teamBScore && (teamCScore == null || teamCScore == teamAScore);

  int get totalGoals => teamAScore + teamBScore + (teamCScore ?? 0);

  String get winnerTeamName {
    if (teamCScore != null) {
      if (teamAScore > teamBScore && teamAScore > teamCScore!) return teamAName;
      if (teamBScore > teamAScore && teamBScore > teamCScore!) return teamBName;
      if (teamCScore! > teamAScore && teamCScore! > teamBScore) return teamCName ?? 'الفريق الثالث (الأسود)';
      return 'تعادل بين الفرق';
    }
    if (teamAScore > teamBScore) return teamAName;
    if (teamBScore > teamAScore) return teamBName;
    return 'تعادل';
  }

  MatchResultEntity copyWith({
    String? id,
    String? matchId,
    int? teamAScore,
    int? teamBScore,
    int? teamCScore,
    String? teamAName,
    String? teamBName,
    String? teamCName,
    List<GoalEventEntity>? goals,
    List<CardEventEntity>? cards,
    String? manOfTheMatchPlayerId,
    String? manOfTheMatchName,
    bool? isLocked,
    DateTime? recordedAt,
    String? notes,
  }) {
    return MatchResultEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      teamCScore: teamCScore ?? this.teamCScore,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      teamCName: teamCName ?? this.teamCName,
      goals: goals ?? this.goals,
      cards: cards ?? this.cards,
      manOfTheMatchPlayerId:
          manOfTheMatchPlayerId ?? this.manOfTheMatchPlayerId,
      manOfTheMatchName: manOfTheMatchName ?? this.manOfTheMatchName,
      isLocked: isLocked ?? this.isLocked,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    matchId,
    teamAScore,
    teamBScore,
    teamCScore,
    teamAName,
    teamBName,
    teamCName,
    goals,
    cards,
    manOfTheMatchPlayerId,
    manOfTheMatchName,
    isLocked,
    recordedAt,
    notes,
  ];
}

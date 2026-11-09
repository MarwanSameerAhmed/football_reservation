import 'package:equatable/equatable.dart';

/// Pure domain entity representing a scored goal event in a football match.
class GoalEventEntity extends Equatable {
  final String id;
  final String scorerPlayerId;
  final String scorerName;
  final String teamName;
  final String? assistPlayerId;
  final String? assistPlayerName;
  final int? minute;
  final bool isPenalty;
  final bool isOwnGoal;

  const GoalEventEntity({
    required this.id,
    required this.scorerPlayerId,
    required this.scorerName,
    required this.teamName,
    this.assistPlayerId,
    this.assistPlayerName,
    this.minute,
    this.isPenalty = false,
    this.isOwnGoal = false,
  });

  GoalEventEntity copyWith({
    String? id,
    String? scorerPlayerId,
    String? scorerName,
    String? teamName,
    String? assistPlayerId,
    String? assistPlayerName,
    int? minute,
    bool? isPenalty,
    bool? isOwnGoal,
  }) {
    return GoalEventEntity(
      id: id ?? this.id,
      scorerPlayerId: scorerPlayerId ?? this.scorerPlayerId,
      scorerName: scorerName ?? this.scorerName,
      teamName: teamName ?? this.teamName,
      assistPlayerId: assistPlayerId ?? this.assistPlayerId,
      assistPlayerName: assistPlayerName ?? this.assistPlayerName,
      minute: minute ?? this.minute,
      isPenalty: isPenalty ?? this.isPenalty,
      isOwnGoal: isOwnGoal ?? this.isOwnGoal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    scorerPlayerId,
    scorerName,
    teamName,
    assistPlayerId,
    assistPlayerName,
    minute,
    isPenalty,
    isOwnGoal,
  ];
}

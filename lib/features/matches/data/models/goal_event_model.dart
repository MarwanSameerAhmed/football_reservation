import '../../domain/entities/goal_event_entity.dart';

class GoalEventModel extends GoalEventEntity {
  const GoalEventModel({
    required super.id,
    required super.scorerPlayerId,
    required super.scorerName,
    required super.teamName,
    super.assistPlayerId,
    super.assistPlayerName,
    super.minute,
    super.isPenalty = false,
    super.isOwnGoal = false,
  });

  factory GoalEventModel.fromEntity(GoalEventEntity entity) {
    return GoalEventModel(
      id: entity.id,
      scorerPlayerId: entity.scorerPlayerId,
      scorerName: entity.scorerName,
      teamName: entity.teamName,
      assistPlayerId: entity.assistPlayerId,
      assistPlayerName: entity.assistPlayerName,
      minute: entity.minute,
      isPenalty: entity.isPenalty,
      isOwnGoal: entity.isOwnGoal,
    );
  }

  factory GoalEventModel.fromJson(Map<String, dynamic> json) {
    return GoalEventModel(
      id: json['id'] as String? ?? '',
      scorerPlayerId: json['scorerPlayerId'] as String? ?? '',
      scorerName: json['scorerName'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      assistPlayerId: json['assistPlayerId'] as String?,
      assistPlayerName: json['assistPlayerName'] as String?,
      minute: json['minute'] as int?,
      isPenalty: json['isPenalty'] as bool? ?? false,
      isOwnGoal: json['isOwnGoal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scorerPlayerId': scorerPlayerId,
      'scorerName': scorerName,
      'teamName': teamName,
      if (assistPlayerId != null) 'assistPlayerId': assistPlayerId,
      if (assistPlayerName != null) 'assistPlayerName': assistPlayerName,
      if (minute != null) 'minute': minute,
      'isPenalty': isPenalty,
      'isOwnGoal': isOwnGoal,
    };
  }
}

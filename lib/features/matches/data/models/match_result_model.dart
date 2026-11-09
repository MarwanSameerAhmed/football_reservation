import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/match_result_entity.dart';
import 'card_event_model.dart';
import 'goal_event_model.dart';

class MatchResultModel extends MatchResultEntity {
  const MatchResultModel({
    required super.id,
    required super.matchId,
    required super.teamAScore,
    required super.teamBScore,
    super.teamAName,
    super.teamBName,
    super.goals,
    super.cards,
    super.manOfTheMatchPlayerId,
    super.manOfTheMatchName,
    super.isLocked,
    required super.recordedAt,
    super.notes,
  });

  factory MatchResultModel.fromEntity(MatchResultEntity entity) {
    return MatchResultModel(
      id: entity.id,
      matchId: entity.matchId,
      teamAScore: entity.teamAScore,
      teamBScore: entity.teamBScore,
      teamAName: entity.teamAName,
      teamBName: entity.teamBName,
      goals: entity.goals.map((g) => GoalEventModel.fromEntity(g)).toList(),
      cards: entity.cards.map((c) => CardEventModel.fromEntity(c)).toList(),
      manOfTheMatchPlayerId: entity.manOfTheMatchPlayerId,
      manOfTheMatchName: entity.manOfTheMatchName,
      isLocked: entity.isLocked,
      recordedAt: entity.recordedAt,
      notes: entity.notes,
    );
  }

  factory MatchResultModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    final rawRecordedAt = json['recordedAt'];
    final recordedAt = rawRecordedAt is Timestamp
        ? rawRecordedAt.toDate()
        : DateTime.tryParse(rawRecordedAt?.toString() ?? '') ?? DateTime.now();

    final rawGoals = (json['goals'] as List<dynamic>?) ?? [];
    final goals = rawGoals
        .map((e) => GoalEventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawCards = (json['cards'] as List<dynamic>?) ?? [];
    final cards = rawCards
        .map((e) => CardEventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MatchResultModel(
      id: docId ?? (json['id'] as String? ?? ''),
      matchId: json['matchId'] as String? ?? '',
      teamAScore: json['teamAScore'] as int? ?? 0,
      teamBScore: json['teamBScore'] as int? ?? 0,
      teamAName: json['teamAName'] as String? ?? 'الفريق الأول (الأخضر)',
      teamBName: json['teamBName'] as String? ?? 'الفريق الثاني (الأبيض)',
      goals: goals,
      cards: cards,
      manOfTheMatchPlayerId: json['manOfTheMatchPlayerId'] as String?,
      manOfTheMatchName: json['manOfTheMatchName'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      recordedAt: recordedAt,
      notes: json['notes'] as String?,
    );
  }

  factory MatchResultModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return MatchResultModel.fromJson(doc.data() ?? {}, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'teamAName': teamAName,
      'teamBName': teamBName,
      'goals': goals.map((g) => GoalEventModel.fromEntity(g).toJson()).toList(),
      'cards': cards.map((c) => CardEventModel.fromEntity(c).toJson()).toList(),
      if (manOfTheMatchPlayerId != null)
        'manOfTheMatchPlayerId': manOfTheMatchPlayerId,
      if (manOfTheMatchName != null) 'manOfTheMatchName': manOfTheMatchName,
      'isLocked': isLocked,
      'recordedAt': Timestamp.fromDate(recordedAt),
      if (notes != null) 'notes': notes,
    };
  }
}

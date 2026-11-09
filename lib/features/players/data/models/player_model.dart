import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/preferred_foot.dart';
import '../../domain/entities/player_entity.dart';
import 'player_skills_model.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.userId,
    required super.name,
    super.nickname,
    super.photoUrl,
    required super.primaryPosition,
    super.secondaryPosition,
    super.preferredFoot,
    super.jerseyNumber,
    required super.skills,
    super.matchesPlayed,
    super.goals,
    super.assists,
    super.isAvailable,
    required super.createdAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PlayerModel(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nickname: json['nickname'] as String?,
      photoUrl: json['photoUrl'] as String?,
      primaryPosition: _parsePosition(json['primaryPosition'] as String?),
      secondaryPosition: json['secondaryPosition'] != null
          ? _parsePosition(json['secondaryPosition'] as String?)
          : null,
      preferredFoot: _parseFoot(json['preferredFoot'] as String?),
      jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
      skills: json['skills'] != null
          ? PlayerSkillsModel.fromJson(json['skills'] as Map<String, dynamic>)
          : const PlayerSkillsModel(
              pace: 70,
              shooting: 65,
              passing: 70,
              defending: 65,
              physical: 70,
            ),
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
                ? (json['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
    );
  }

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlayerModel.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'primaryPosition': primaryPosition.name,
      'secondaryPosition': secondaryPosition?.name,
      'preferredFoot': preferredFoot.name,
      'jerseyNumber': jerseyNumber,
      'skills': PlayerSkillsModel.fromEntity(skills).toJson(),
      'matchesPlayed': matchesPlayed,
      'goals': goals,
      'assists': assists,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      nickname: entity.nickname,
      photoUrl: entity.photoUrl,
      primaryPosition: entity.primaryPosition,
      secondaryPosition: entity.secondaryPosition,
      preferredFoot: entity.preferredFoot,
      jerseyNumber: entity.jerseyNumber,
      skills: entity.skills,
      matchesPlayed: entity.matchesPlayed,
      goals: entity.goals,
      assists: entity.assists,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
    );
  }

  static PlayerPosition _parsePosition(String? value) {
    if (value == null) return PlayerPosition.midfielder;
    return PlayerPosition.values.firstWhere(
      (p) => p.name == value,
      orElse: () => PlayerPosition.midfielder,
    );
  }

  static PreferredFoot _parseFoot(String? value) {
    if (value == null) return PreferredFoot.right;
    return PreferredFoot.values.firstWhere(
      (f) => f.name == value,
      orElse: () => PreferredFoot.right,
    );
  }
}

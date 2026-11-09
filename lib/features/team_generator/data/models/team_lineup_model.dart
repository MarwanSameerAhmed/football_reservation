import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/generated_team_entity.dart';
import '../../domain/entities/team_lineup_entity.dart';
import 'generated_team_model.dart';

class TeamLineupModel extends TeamLineupEntity {
  const TeamLineupModel({
    required super.id,
    required super.matchId,
    required super.teams,
    required super.generatedAt,
    super.isFinalized,
  });

  factory TeamLineupModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final teamsJson = json['teams'] as List<dynamic>?;
    final List<GeneratedTeamEntity> teams;
    if (teamsJson != null && teamsJson.isNotEmpty) {
      teams = teamsJson
          .map((t) => GeneratedTeamModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } else {
      teams = [
        if (json['teamA'] != null)
          GeneratedTeamModel.fromJson(json['teamA'] as Map<String, dynamic>),
        if (json['teamB'] != null)
          GeneratedTeamModel.fromJson(json['teamB'] as Map<String, dynamic>),
      ];
    }

    return TeamLineupModel(
      id: id ?? json['id'] as String? ?? '',
      matchId: json['matchId'] as String? ?? '',
      teams: teams,
      generatedAt: json['generatedAt'] != null
          ? (json['generatedAt'] is Timestamp
                ? (json['generatedAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['generatedAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      isFinalized: json['isFinalized'] as bool? ?? false,
    );
  }

  factory TeamLineupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TeamLineupModel.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'teams': teams
          .map((t) => GeneratedTeamModel.fromEntity(t).toJson())
          .toList(),
      if (teams.isNotEmpty)
        'teamA': GeneratedTeamModel.fromEntity(teamA).toJson(),
      if (teams.length > 1)
        'teamB': GeneratedTeamModel.fromEntity(teamB).toJson(),
      'generatedAt': Timestamp.fromDate(generatedAt),
      'isFinalized': isFinalized,
    };
  }

  factory TeamLineupModel.fromEntity(TeamLineupEntity entity) {
    return TeamLineupModel(
      id: entity.id,
      matchId: entity.matchId,
      teams: entity.teams,
      generatedAt: entity.generatedAt,
      isFinalized: entity.isFinalized,
    );
  }
}

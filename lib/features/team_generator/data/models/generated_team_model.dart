import '../../../players/data/models/player_model.dart';
import '../../domain/entities/generated_team_entity.dart';

class GeneratedTeamModel extends GeneratedTeamEntity {
  const GeneratedTeamModel({
    required super.id,
    required super.name,
    required super.bibColor,
    required super.players,
  });

  factory GeneratedTeamModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] as List<dynamic>? ?? [];
    final playersList = rawPlayers
        .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return GeneratedTeamModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bibColor: json['bibColor'] as String? ?? 'أخضر عشبي',
      players: playersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bibColor': bibColor,
      'players': players
          .map((p) => PlayerModel.fromEntity(p).toJson())
          .toList(),
    };
  }

  factory GeneratedTeamModel.fromEntity(GeneratedTeamEntity entity) {
    return GeneratedTeamModel(
      id: entity.id,
      name: entity.name,
      bibColor: entity.bibColor,
      players: entity.players,
    );
  }
}

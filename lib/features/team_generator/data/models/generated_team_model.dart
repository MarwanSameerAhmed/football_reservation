import '../../../players/data/models/player_model.dart';
import '../../domain/entities/generated_team_entity.dart';

class GeneratedTeamModel extends GeneratedTeamEntity {
  const GeneratedTeamModel({
    required super.id,
    required super.name,
    required super.bibColor,
    required super.players,
    super.captainPlayerId,
    super.goalkeeperRotation = const [],
  });

  factory GeneratedTeamModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] as List<dynamic>? ?? [];
    final playersList = rawPlayers
        .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final rawRotation = json['goalkeeperRotation'] as List<dynamic>? ?? [];
    final rotationList = rawRotation.map((e) => e.toString()).toList();

    return GeneratedTeamModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bibColor: json['bibColor'] as String? ?? 'أخضر عشبي',
      players: playersList,
      captainPlayerId: json['captainPlayerId'] as String?,
      goalkeeperRotation: rotationList,
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
      'captainPlayerId': captainPlayerId,
      'goalkeeperRotation': goalkeeperRotation,
    };
  }

  factory GeneratedTeamModel.fromEntity(GeneratedTeamEntity entity) {
    return GeneratedTeamModel(
      id: entity.id,
      name: entity.name,
      bibColor: entity.bibColor,
      players: entity.players,
      captainPlayerId: entity.captainPlayerId,
      goalkeeperRotation: entity.goalkeeperRotation,
    );
  }
}

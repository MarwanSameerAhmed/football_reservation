import '../../../../core/enums/player_position.dart';
import '../../domain/entities/player_stats_entity.dart';

class PlayerStatsModel extends PlayerStatsEntity {
  const PlayerStatsModel({
    required super.playerId,
    required super.playerName,
    super.photoUrl,
    required super.position,
    super.matchesPlayed,
    super.goals,
    super.assists,
    super.cleanSheets,
    super.motmAwards,
    super.wins,
    super.draws,
    super.losses,
  });

  factory PlayerStatsModel.fromEntity(PlayerStatsEntity entity) {
    return PlayerStatsModel(
      playerId: entity.playerId,
      playerName: entity.playerName,
      photoUrl: entity.photoUrl,
      position: entity.position,
      matchesPlayed: entity.matchesPlayed,
      goals: entity.goals,
      assists: entity.assists,
      cleanSheets: entity.cleanSheets,
      motmAwards: entity.motmAwards,
      wins: entity.wins,
      draws: entity.draws,
      losses: entity.losses,
    );
  }

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      playerId: json['playerId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      position: PlayerPosition.values.firstWhere(
        (p) => p.name == json['position'],
        orElse: () => PlayerPosition.midfielder,
      ),
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      cleanSheets: (json['cleanSheets'] as num?)?.toInt() ?? 0,
      motmAwards: (json['motmAwards'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'position': position.name,
      'matchesPlayed': matchesPlayed,
      'goals': goals,
      'assists': assists,
      'cleanSheets': cleanSheets,
      'motmAwards': motmAwards,
      'wins': wins,
      'draws': draws,
      'losses': losses,
    };
  }
}

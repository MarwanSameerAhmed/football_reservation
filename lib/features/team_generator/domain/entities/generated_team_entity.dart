import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';
import '../../../players/domain/entities/player_entity.dart';

class GeneratedTeamEntity extends Equatable {
  final String id;
  final String name; // e.g. 'الفريق (أ)' or 'Team A'
  final String bibColor; // e.g. 'أخضر عشبي' or 'أسود داكن'
  final List<PlayerEntity> players;
  final String? captainPlayerId;
  final List<String> goalkeeperRotation; // Player IDs in randomized rotation order (1st, 2nd, 3rd, ...)

  const GeneratedTeamEntity({
    required this.id,
    required this.name,
    required this.bibColor,
    required this.players,
    this.captainPlayerId,
    this.goalkeeperRotation = const [],
  });

  PlayerEntity? get captain {
    if (captainPlayerId == null) return null;
    for (final p in players) {
      if (p.id == captainPlayerId) return p;
    }
    return null;
  }

  bool isCaptain(String playerId) => captainPlayerId == playerId;

  int getGoalkeeperOrder(String playerId) {
    final index = goalkeeperRotation.indexOf(playerId);
    return index != -1 ? index + 1 : -1;
  }

  List<PlayerEntity> get goalkeeperRotationPlayers {
    if (goalkeeperRotation.isEmpty) return players;
    final map = {for (var p in players) p.id: p};
    final ordered = <PlayerEntity>[];
    for (final id in goalkeeperRotation) {
      if (map.containsKey(id)) {
        ordered.add(map[id]!);
      }
    }
    for (final p in players) {
      if (!ordered.contains(p)) {
        ordered.add(p);
      }
    }
    return ordered;
  }

  int get totalScore =>
      players.fold(0, (sum, p) => sum + p.skills.overallScore);

  double get averageRating {
    if (players.isEmpty) return 0.0;
    final total = players.fold(0.0, (sum, p) => sum + p.rating);
    return (total / players.length * 10).round() / 10;
  }

  int countPosition(PlayerPosition pos) =>
      players.where((p) => p.primaryPosition == pos).length;

  GeneratedTeamEntity copyWith({
    String? id,
    String? name,
    String? bibColor,
    List<PlayerEntity>? players,
    String? captainPlayerId,
    List<String>? goalkeeperRotation,
  }) {
    return GeneratedTeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bibColor: bibColor ?? this.bibColor,
      players: players ?? this.players,
      captainPlayerId: captainPlayerId ?? this.captainPlayerId,
      goalkeeperRotation: goalkeeperRotation ?? this.goalkeeperRotation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        bibColor,
        players,
        captainPlayerId,
        goalkeeperRotation,
      ];
}

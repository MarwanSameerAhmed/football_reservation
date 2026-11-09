import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';
import '../../../players/domain/entities/player_entity.dart';

class GeneratedTeamEntity extends Equatable {
  final String id;
  final String name; // e.g. 'الفريق (أ)' or 'Team A'
  final String bibColor; // e.g. 'أخضر عشبي' or 'أسود داكن'
  final List<PlayerEntity> players;

  const GeneratedTeamEntity({
    required this.id,
    required this.name,
    required this.bibColor,
    required this.players,
  });

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
  }) {
    return GeneratedTeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bibColor: bibColor ?? this.bibColor,
      players: players ?? this.players,
    );
  }

  @override
  List<Object?> get props => [id, name, bibColor, players];
}

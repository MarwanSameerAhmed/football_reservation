import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_skills.dart';

abstract class PlayersEvent extends Equatable {
  const PlayersEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch list of players, optionally filtered by position and query.
class LoadPlayersRequested extends PlayersEvent {
  final PlayerPosition? positionFilter;
  final String? searchQuery;

  const LoadPlayersRequested({this.positionFilter, this.searchQuery});

  @override
  List<Object?> get props => [positionFilter, searchQuery];
}

/// Filter currently loaded players by position.
class FilterPlayersByPosition extends PlayersEvent {
  final PlayerPosition? position;

  const FilterPlayersByPosition(this.position);

  @override
  List<Object?> get props => [position];
}

/// Search players by query string.
class SearchPlayersQueryChanged extends PlayersEvent {
  final String query;

  const SearchPlayersQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Admin action to update player skills.
class UpdatePlayerSkillsSubmitted extends PlayersEvent {
  final String playerId;
  final PlayerSkills skills;
  final UserRole updaterRole;

  const UpdatePlayerSkillsSubmitted({
    required this.playerId,
    required this.skills,
    required this.updaterRole,
  });

  @override
  List<Object?> get props => [playerId, skills, updaterRole];
}

/// Admin action to add a new player to the group.
class AddPlayerSubmitted extends PlayersEvent {
  final PlayerEntity player;

  const AddPlayerSubmitted(this.player);

  @override
  List<Object?> get props => [player];
}

/// Update player avatar or photo URL.
class UpdatePlayerPhotoRequested extends PlayersEvent {
  final String playerId;
  final String photoUrl;

  const UpdatePlayerPhotoRequested({
    required this.playerId,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [playerId, photoUrl];
}

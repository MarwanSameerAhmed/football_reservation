import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';
import '../../domain/entities/player_entity.dart';

abstract class PlayersState extends Equatable {
  const PlayersState();

  @override
  List<Object?> get props => [];
}

class PlayersInitial extends PlayersState {
  const PlayersInitial();
}

class PlayersLoading extends PlayersState {
  const PlayersLoading();
}

class PlayersLoaded extends PlayersState {
  final List<PlayerEntity> allPlayers;
  final List<PlayerEntity> filteredPlayers;
  final PlayerPosition? selectedPosition;
  final String searchQuery;

  const PlayersLoaded({
    required this.allPlayers,
    required this.filteredPlayers,
    this.selectedPosition,
    this.searchQuery = '',
  });

  PlayersLoaded copyWith({
    List<PlayerEntity>? allPlayers,
    List<PlayerEntity>? filteredPlayers,
    PlayerPosition? selectedPosition,
    bool clearPositionFilter = false,
    String? searchQuery,
  }) {
    return PlayersLoaded(
      allPlayers: allPlayers ?? this.allPlayers,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      selectedPosition: clearPositionFilter
          ? null
          : (selectedPosition ?? this.selectedPosition),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allPlayers,
    filteredPlayers,
    selectedPosition,
    searchQuery,
  ];
}

class PlayersEmptyState extends PlayersState {
  final String message;
  const PlayersEmptyState([this.message = 'لا يوجد لاعبون مسجلون']);

  @override
  List<Object?> get props => [message];
}

class PlayersErrorState extends PlayersState {
  final String errorMessage;
  const PlayersErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

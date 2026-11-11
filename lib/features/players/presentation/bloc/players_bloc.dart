import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/player_position.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/usecases/create_player_usecase.dart';
import '../../domain/usecases/get_players_usecase.dart';
import '../../domain/usecases/update_player_skills_usecase.dart';
import 'players_event.dart';
import 'players_state.dart';

class PlayersBloc extends Bloc<PlayersEvent, PlayersState> {
  final GetPlayersUseCase _getPlayersUseCase;
  final UpdatePlayerSkillsUseCase _updatePlayerSkillsUseCase;
  final CreatePlayerUseCase? _createPlayerUseCase;

  PlayersBloc({
    required GetPlayersUseCase getPlayersUseCase,
    required UpdatePlayerSkillsUseCase updatePlayerSkillsUseCase,
    CreatePlayerUseCase? createPlayerUseCase,
  }) : _getPlayersUseCase = getPlayersUseCase,
       _updatePlayerSkillsUseCase = updatePlayerSkillsUseCase,
       _createPlayerUseCase = createPlayerUseCase,
       super(const PlayersInitial()) {
    on<LoadPlayersRequested>(_onLoadPlayersRequested);
    on<FilterPlayersByPosition>(_onFilterPlayersByPosition);
    on<SearchPlayersQueryChanged>(_onSearchPlayersQueryChanged);
    on<UpdatePlayerSkillsSubmitted>(_onUpdatePlayerSkillsSubmitted);
    on<AddPlayerSubmitted>(_onAddPlayerSubmitted);
    on<UpdatePlayerPhotoRequested>(_onUpdatePlayerPhotoRequested);
  }

  Future<void> _onLoadPlayersRequested(
    LoadPlayersRequested event,
    Emitter<PlayersState> emit,
  ) async {
    emit(const PlayersLoading());
    final result = await _getPlayersUseCase(
      positionFilter: event.positionFilter,
      searchQuery: event.searchQuery,
    );

    result.fold(
      onSuccess: (players) {
        if (players.isEmpty) {
          emit(const PlayersEmptyState());
        } else {
          emit(
            PlayersLoaded(
              allPlayers: players,
              filteredPlayers: players,
              selectedPosition: event.positionFilter,
              searchQuery: event.searchQuery ?? '',
            ),
          );
        }
      },
      onFailure: (failure) => emit(PlayersErrorState(failure.message)),
    );
  }

  void _onFilterPlayersByPosition(
    FilterPlayersByPosition event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is PlayersLoaded) {
      final filtered = _applyFilters(
        currentState.allPlayers,
        position: event.position,
        query: currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          selectedPosition: event.position,
          clearPositionFilter: event.position == null,
          filteredPlayers: filtered,
        ),
      );
    }
  }

  void _onSearchPlayersQueryChanged(
    SearchPlayersQueryChanged event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is PlayersLoaded) {
      final filtered = _applyFilters(
        currentState.allPlayers,
        position: currentState.selectedPosition,
        query: event.query,
      );

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredPlayers: filtered,
        ),
      );
    }
  }

  Future<void> _onUpdatePlayerSkillsSubmitted(
    UpdatePlayerSkillsSubmitted event,
    Emitter<PlayersState> emit,
  ) async {
    final currentState = state;
    final result = await _updatePlayerSkillsUseCase(
      playerId: event.playerId,
      skills: event.skills,
      updaterRole: event.updaterRole,
    );

    result.fold(
      onSuccess: (updatedPlayer) {
        if (currentState is PlayersLoaded) {
          final updatedAll = currentState.allPlayers.map((p) {
            return p.id == updatedPlayer.id ? updatedPlayer : p;
          }).toList();

          final updatedFiltered = _applyFilters(
            updatedAll,
            position: currentState.selectedPosition,
            query: currentState.searchQuery,
          );

          emit(
            currentState.copyWith(
              allPlayers: updatedAll,
              filteredPlayers: updatedFiltered,
            ),
          );
        }
      },
      onFailure: (failure) {
        emit(PlayersErrorState(failure.message));
      },
    );
  }

  Future<void> _onAddPlayerSubmitted(
    AddPlayerSubmitted event,
    Emitter<PlayersState> emit,
  ) async {
    if (_createPlayerUseCase != null) {
      final result = await _createPlayerUseCase(event.player);
      result.fold(
        onSuccess: (newPlayer) {
          final currentState = state;
          if (currentState is PlayersLoaded) {
            final updatedAll = [newPlayer, ...currentState.allPlayers];
            final updatedFiltered = _applyFilters(
              updatedAll,
              position: currentState.selectedPosition,
              query: currentState.searchQuery,
            );
            emit(
              currentState.copyWith(
                allPlayers: updatedAll,
                filteredPlayers: updatedFiltered,
              ),
            );
          } else {
            emit(
              PlayersLoaded(
                allPlayers: [newPlayer],
                filteredPlayers: [newPlayer],
                searchQuery: '',
              ),
            );
          }
        },
        onFailure: (failure) {
          emit(PlayersErrorState(failure.message));
        },
      );
    } else {
      // Fallback if usecase not injected
      final currentState = state;
      if (currentState is PlayersLoaded) {
        final updatedAll = [event.player, ...currentState.allPlayers];
        final updatedFiltered = _applyFilters(
          updatedAll,
          position: currentState.selectedPosition,
          query: currentState.searchQuery,
        );
        emit(
          currentState.copyWith(
            allPlayers: updatedAll,
            filteredPlayers: updatedFiltered,
          ),
        );
      }
    }
  }

  void _onUpdatePlayerPhotoRequested(
    UpdatePlayerPhotoRequested event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is PlayersLoaded) {
      final updatedAll = currentState.allPlayers.map((p) {
        if (p.id == event.playerId || p.userId == event.playerId) {
          return p.copyWith(photoUrl: event.photoUrl);
        }
        return p;
      }).toList();

      final updatedFiltered = _applyFilters(
        updatedAll,
        position: currentState.selectedPosition,
        query: currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          allPlayers: updatedAll,
          filteredPlayers: updatedFiltered,
        ),
      );
    }
  }

  List<PlayerEntity> _applyFilters(
    List<PlayerEntity> players, {
    PlayerPosition? position,
    required String query,
  }) {
    var result = players;
    if (position != null) {
      result = result.where((p) => p.primaryPosition == position).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.nickname != null && p.nickname!.toLowerCase().contains(q)),
          )
          .toList();
    }
    return result;
  }
}

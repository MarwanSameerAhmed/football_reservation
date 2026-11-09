import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firebase_notification_sender_service.dart';
import '../../domain/usecases/generate_balanced_teams_usecase.dart';
import '../../domain/usecases/get_lineup_history_usecase.dart';
import '../../domain/usecases/save_final_lineup_usecase.dart';
import '../../domain/usecases/swap_players_usecase.dart';
import 'team_generator_event.dart';
import 'team_generator_state.dart';

class TeamGeneratorBloc extends Bloc<TeamGeneratorEvent, TeamGeneratorState> {
  final GenerateBalancedTeamsUseCase _generateBalancedTeamsUseCase;
  final SwapPlayersUseCase _swapPlayersUseCase;
  final SaveFinalLineupUseCase _saveFinalLineupUseCase;
  final GetLineupHistoryUseCase _getLineupHistoryUseCase;
  final FirebaseNotificationSenderService? _notificationSenderService;

  TeamGeneratorBloc({
    required GenerateBalancedTeamsUseCase generateBalancedTeamsUseCase,
    required SwapPlayersUseCase swapPlayersUseCase,
    required SaveFinalLineupUseCase saveFinalLineupUseCase,
    required GetLineupHistoryUseCase getLineupHistoryUseCase,
    FirebaseNotificationSenderService? notificationSenderService,
  }) : _generateBalancedTeamsUseCase = generateBalancedTeamsUseCase,
       _swapPlayersUseCase = swapPlayersUseCase,
       _saveFinalLineupUseCase = saveFinalLineupUseCase,
       _getLineupHistoryUseCase = getLineupHistoryUseCase,
       _notificationSenderService = notificationSenderService,
       super(const TeamGeneratorInitial()) {
    on<GenerateBalancedTeamsRequested>(_onGenerateBalancedTeamsRequested);
    on<SwapPlayersRequested>(_onSwapPlayersRequested);
    on<SelectPlayerForSwapRequested>(_onSelectPlayerForSwapRequested);
    on<ClearSwapSelectionRequested>(_onClearSwapSelectionRequested);
    on<SaveFinalLineupRequested>(_onSaveFinalLineupRequested);
    on<LoadLineupHistoryRequested>(_onLoadLineupHistoryRequested);
  }

  Future<void> _onGenerateBalancedTeamsRequested(
    GenerateBalancedTeamsRequested event,
    Emitter<TeamGeneratorState> emit,
  ) async {
    emit(const TeamGeneratorLoading(message: 'جاري إنشاء الفرق المتوازنة...'));
    final result = await _generateBalancedTeamsUseCase(
      players: event.players,
      matchId: event.matchId,
    );
    result.fold(
      onSuccess: (lineup) {
        emit(
          TeamGeneratorSuccess(
            currentLineup: lineup,
            feedbackMessage: 'تم إنشاء التشكيلة بتوازن دقيق',
          ),
        );
      },
      onFailure: (failure) => emit(TeamGeneratorErrorState(failure.message)),
    );
  }

  Future<void> _onSelectPlayerForSwapRequested(
    SelectPlayerForSwapRequested event,
    Emitter<TeamGeneratorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeamGeneratorSuccess ||
        currentState.currentLineup == null) {
      return;
    }

    final selected = currentState.selectedPlayerForSwap;
    if (selected == null) {
      // First player selected
      emit(currentState.copyWith(selectedPlayerForSwap: event.player));
      return;
    }

    if (selected.id == event.player.id) {
      // Tapped the same player -> deselect
      emit(currentState.copyWith(clearSelectedPlayer: true));
      return;
    }

    // Check if they are in different teams
    final lineup = currentState.currentLineup!;
    final teamIndexSelected = lineup.teams.indexWhere(
      (t) => t.players.any((p) => p.id == selected.id),
    );
    final teamIndexEvent = lineup.teams.indexWhere(
      (t) => t.players.any((p) => p.id == event.player.id),
    );

    if (teamIndexSelected == teamIndexEvent ||
        teamIndexSelected == -1 ||
        teamIndexEvent == -1) {
      // Both are in the same team -> switch selection to new player
      emit(currentState.copyWith(selectedPlayerForSwap: event.player));
      return;
    }

    // Players are in different teams -> perform swap
    emit(currentState.copyWith(clearSelectedPlayer: true));
    add(
      SwapPlayersRequested(
        lineup: lineup,
        playerAId: selected.id,
        playerBId: event.player.id,
      ),
    );
  }

  void _onClearSwapSelectionRequested(
    ClearSwapSelectionRequested event,
    Emitter<TeamGeneratorState> emit,
  ) {
    if (state is TeamGeneratorSuccess) {
      emit((state as TeamGeneratorSuccess).copyWith(clearSelectedPlayer: true));
    }
  }

  Future<void> _onSwapPlayersRequested(
    SwapPlayersRequested event,
    Emitter<TeamGeneratorState> emit,
  ) async {
    final currentState = state;
    final history = currentState is TeamGeneratorSuccess
        ? currentState.history
        : <dynamic>[];

    final result = await _swapPlayersUseCase(
      lineup: event.lineup,
      playerAId: event.playerAId,
      playerBId: event.playerBId,
    );

    result.fold(
      onSuccess: (updatedLineup) {
        emit(
          TeamGeneratorSuccess(
            currentLineup: updatedLineup,
            selectedPlayerForSwap: null,
            history: history.cast(),
            feedbackMessage: 'تم تبديل اللاعبين وتحديث التوازن بنجاح',
          ),
        );
      },
      onFailure: (failure) => emit(TeamGeneratorErrorState(failure.message)),
    );
  }

  Future<void> _onSaveFinalLineupRequested(
    SaveFinalLineupRequested event,
    Emitter<TeamGeneratorState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeamGeneratorSuccess) {
      emit(currentState.copyWith(isSaving: true));
    }

    final result = await _saveFinalLineupUseCase(event.lineup);

    result.fold(
      onSuccess: (finalLineup) {
        // Trigger FCM push notification to announce teams to all players
        _notificationSenderService?.sendTeamsPublishedNotification(
          matchId: finalLineup.matchId,
          matchTitle: 'المباراة القادمة',
        );

        if (state is TeamGeneratorSuccess) {
          final s = state as TeamGeneratorSuccess;
          emit(
            s.copyWith(
              currentLineup: finalLineup,
              isSaving: false,
              feedbackMessage: 'تم اعتماد وتثبيت التشكيلة للمباراة بنجاح',
            ),
          );
        } else {
          emit(
            TeamGeneratorSuccess(
              currentLineup: finalLineup,
              feedbackMessage: 'تم اعتماد وتثبيت التشكيلة للمباراة بنجاح',
            ),
          );
        }
      },
      onFailure: (failure) {
        if (state is TeamGeneratorSuccess) {
          emit(
            (state as TeamGeneratorSuccess).copyWith(
              isSaving: false,
              feedbackMessage: failure.message,
            ),
          );
        } else {
          emit(TeamGeneratorErrorState(failure.message));
        }
      },
    );
  }

  Future<void> _onLoadLineupHistoryRequested(
    LoadLineupHistoryRequested event,
    Emitter<TeamGeneratorState> emit,
  ) async {
    final result = await _getLineupHistoryUseCase(matchId: event.matchId);
    result.fold(
      onSuccess: (historyList) {
        if (state is TeamGeneratorSuccess) {
          emit((state as TeamGeneratorSuccess).copyWith(history: historyList));
        } else {
          emit(TeamGeneratorSuccess(history: historyList));
        }
      },
      onFailure: (failure) => emit(TeamGeneratorErrorState(failure.message)),
    );
  }
}

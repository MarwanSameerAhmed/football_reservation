import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/close_poll_usecase.dart';
import '../../domain/usecases/create_poll_usecase.dart';
import '../../domain/usecases/get_poll_by_id_usecase.dart';
import '../../domain/usecases/get_polls_usecase.dart';
import '../../domain/usecases/vote_poll_usecase.dart';
import 'polls_event.dart';
import 'polls_state.dart';

class PollsBloc extends Bloc<PollsEvent, PollsState> {
  final GetPollsUseCase _getPollsUseCase;
  final GetPollByIdUseCase _getPollByIdUseCase;
  final CreatePollUseCase _createPollUseCase;
  final VotePollUseCase _votePollUseCase;
  final ClosePollUseCase _closePollUseCase;

  PollsBloc({
    required GetPollsUseCase getPollsUseCase,
    required GetPollByIdUseCase getPollByIdUseCase,
    required CreatePollUseCase createPollUseCase,
    required VotePollUseCase votePollUseCase,
    required ClosePollUseCase closePollUseCase,
  }) : _getPollsUseCase = getPollsUseCase,
       _getPollByIdUseCase = getPollByIdUseCase,
       _createPollUseCase = createPollUseCase,
       _votePollUseCase = votePollUseCase,
       _closePollUseCase = closePollUseCase,
       super(const PollsInitial()) {
    on<LoadPollsRequested>(_onLoadPollsRequested);
    on<SelectPollRequested>(_onSelectPollRequested);
    on<CastVoteRequested>(_onCastVoteRequested);
    on<CreatePollRequested>(_onCreatePollRequested);
    on<ClosePollRequested>(_onClosePollRequested);
  }

  Future<void> _onLoadPollsRequested(
    LoadPollsRequested event,
    Emitter<PollsState> emit,
  ) async {
    emit(const PollsLoading());
    final result = await _getPollsUseCase(
      matchId: event.matchId,
      activeOnly: event.activeOnly,
    );

    result.fold(
      onSuccess: (polls) {
        if (polls.isEmpty) {
          emit(const PollsEmptyState());
        } else {
          emit(PollsLoaded(polls: polls, selectedPoll: polls.first));
        }
      },
      onFailure: (failure) => emit(PollsErrorState(failure.message)),
    );
  }

  Future<void> _onSelectPollRequested(
    SelectPollRequested event,
    Emitter<PollsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PollsLoaded) {
      final match =
          currentState.polls.where((p) => p.id == event.pollId).firstOrNull ??
          currentState.selectedPoll;
      emit(currentState.copyWith(selectedPoll: match));
    } else {
      final result = await _getPollByIdUseCase(event.pollId);
      result.fold(
        onSuccess: (poll) =>
            emit(PollsLoaded(polls: [poll], selectedPoll: poll)),
        onFailure: (failure) => emit(PollsErrorState(failure.message)),
      );
    }
  }

  Future<void> _onCastVoteRequested(
    CastVoteRequested event,
    Emitter<PollsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PollsLoaded) {
      emit(currentState.copyWith(isVoting: true));
    }

    final result = await _votePollUseCase(
      pollId: event.pollId,
      optionId: event.optionId,
      userId: event.userId,
    );

    result.fold(
      onSuccess: (updatedPoll) {
        if (state is PollsLoaded) {
          final s = state as PollsLoaded;
          final updatedList = s.polls.map((p) {
            return p.id == updatedPoll.id ? updatedPoll : p;
          }).toList();

          emit(
            s.copyWith(
              polls: updatedList,
              selectedPoll: updatedPoll,
              isVoting: false,
              feedbackMessage: 'تم تسجيل صوتك بنجاح ⚽',
            ),
          );
        } else {
          emit(
            PollsLoaded(
              polls: [updatedPoll],
              selectedPoll: updatedPoll,
              feedbackMessage: 'تم تسجيل صوتك بنجاح ⚽',
            ),
          );
        }
      },
      onFailure: (failure) {
        if (state is PollsLoaded) {
          emit(
            (state as PollsLoaded).copyWith(
              isVoting: false,
              feedbackMessage: failure.message,
            ),
          );
        } else {
          emit(PollsErrorState(failure.message));
        }
      },
    );
  }

  Future<void> _onCreatePollRequested(
    CreatePollRequested event,
    Emitter<PollsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PollsLoaded) {
      emit(currentState.copyWith(isCreating: true));
    }

    final result = await _createPollUseCase(event.poll);

    result.fold(
      onSuccess: (createdPoll) {
        if (state is PollsLoaded) {
          final s = state as PollsLoaded;
          final list = [createdPoll, ...s.polls];
          emit(
            s.copyWith(
              polls: list,
              selectedPoll: createdPoll,
              isCreating: false,
              feedbackMessage: 'تم إنشاء الاستطلاع بنجاح 📋',
            ),
          );
        } else {
          emit(
            PollsLoaded(
              polls: [createdPoll],
              selectedPoll: createdPoll,
              feedbackMessage: 'تم إنشاء الاستطلاع بنجاح 📋',
            ),
          );
        }
      },
      onFailure: (failure) {
        if (state is PollsLoaded) {
          emit(
            (state as PollsLoaded).copyWith(
              isCreating: false,
              feedbackMessage: failure.message,
            ),
          );
        } else {
          emit(PollsErrorState(failure.message));
        }
      },
    );
  }

  Future<void> _onClosePollRequested(
    ClosePollRequested event,
    Emitter<PollsState> emit,
  ) async {
    final result = await _closePollUseCase(event.pollId);

    result.fold(
      onSuccess: (closedPoll) {
        if (state is PollsLoaded) {
          final s = state as PollsLoaded;
          final updatedList = s.polls.map((p) {
            return p.id == closedPoll.id ? closedPoll : p;
          }).toList();

          emit(
            s.copyWith(
              polls: updatedList,
              selectedPoll: closedPoll,
              feedbackMessage: 'تم إغلاق التصويت واعتماد الخيار الفائز 🏆',
            ),
          );
        } else {
          emit(
            PollsLoaded(
              polls: [closedPoll],
              selectedPoll: closedPoll,
              feedbackMessage: 'تم إغلاق التصويت واعتماد الخيار الفائز 🏆',
            ),
          );
        }
      },
      onFailure: (failure) {
        if (state is PollsLoaded) {
          emit(
            (state as PollsLoaded).copyWith(feedbackMessage: failure.message),
          );
        } else {
          emit(PollsErrorState(failure.message));
        }
      },
    );
  }
}

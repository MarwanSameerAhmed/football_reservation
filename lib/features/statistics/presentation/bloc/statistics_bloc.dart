import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_group_leaderboards_usecase.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetGroupLeaderboardsUseCase _getGroupLeaderboardsUseCase;

  StatisticsBloc({
    required GetGroupLeaderboardsUseCase getGroupLeaderboardsUseCase,
  }) : _getGroupLeaderboardsUseCase = getGroupLeaderboardsUseCase,
       super(const StatisticsInitial()) {
    on<LoadStatisticsRequested>(_onLoadStatisticsRequested);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onLoadStatisticsRequested(
    LoadStatisticsRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());
    final result = await _getGroupLeaderboardsUseCase();
    result.fold(
      onSuccess: (leaderboard) {
        if (leaderboard.allPlayers.isEmpty) {
          emit(const StatisticsEmptyState());
        } else {
          emit(StatisticsLoaded(leaderboard: leaderboard));
        }
      },
      onFailure: (failure) => emit(StatisticsErrorState(failure.message)),
    );
  }

  void _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<StatisticsState> emit,
  ) {
    final currentState = state;
    if (currentState is StatisticsLoaded) {
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }
}

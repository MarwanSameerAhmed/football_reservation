import 'package:equatable/equatable.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../domain/entities/group_leaderboard_entity.dart';
import '../../domain/entities/player_stats_entity.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsEmptyState extends StatisticsState {
  const StatisticsEmptyState();
}

class StatisticsLoaded extends StatisticsState {
  final GroupLeaderboardEntity leaderboard;
  final StatisticsCategory selectedCategory;

  const StatisticsLoaded({
    required this.leaderboard,
    this.selectedCategory = StatisticsCategory.goals,
  });

  List<PlayerStatsEntity> get rankedPlayers => switch (selectedCategory) {
    StatisticsCategory.goals => leaderboard.topScorers,
    StatisticsCategory.assists => leaderboard.topAssisters,
    StatisticsCategory.cleanSheets => leaderboard.topCleanSheets,
    StatisticsCategory.motm => leaderboard.topMotm,
  };

  StatisticsLoaded copyWith({
    GroupLeaderboardEntity? leaderboard,
    StatisticsCategory? selectedCategory,
  }) {
    return StatisticsLoaded(
      leaderboard: leaderboard ?? this.leaderboard,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [leaderboard, selectedCategory];
}

class StatisticsErrorState extends StatisticsState {
  final String message;

  const StatisticsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

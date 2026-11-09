import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/player_position.dart';
import 'package:football_reservation/core/enums/statistics_category.dart';
import 'package:football_reservation/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:football_reservation/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:football_reservation/features/statistics/domain/entities/group_leaderboard_entity.dart';
import 'package:football_reservation/features/statistics/domain/entities/player_stats_entity.dart';
import 'package:football_reservation/features/statistics/domain/usecases/get_group_leaderboards_usecase.dart';
import 'package:football_reservation/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:football_reservation/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:football_reservation/features/statistics/presentation/bloc/statistics_state.dart';

void main() {
  group('Player & Group Statistics Domain Logic Tests', () {
    test(
      'Calculates win rate, goal contributions, and averages accurately',
      () {
        const stats = PlayerStatsEntity(
          playerId: 'p1',
          playerName: 'مروان',
          position: PlayerPosition.midfielder,
          matchesPlayed: 10,
          goals: 6,
          assists: 4,
          wins: 7,
          draws: 2,
          losses: 1,
        );

        expect(stats.winRate, equals(70.0));
        expect(stats.goalContributions, equals(10));
        expect(stats.goalsPerMatch, equals(0.6));
      },
    );

    test('Zero matches played safely returns 0.0 without divide by zero', () {
      const emptyStats = PlayerStatsEntity(
        playerId: 'p0',
        playerName: 'جديد',
        position: PlayerPosition.defender,
      );

      expect(emptyStats.winRate, equals(0.0));
      expect(emptyStats.goalsPerMatch, equals(0.0));
    });

    test('GroupLeaderboard calculates average goals per match properly', () {
      const leaderboard = GroupLeaderboardEntity(
        topScorers: [],
        topAssisters: [],
        topCleanSheets: [],
        topMotm: [],
        allPlayers: [],
        totalMatches: 20,
        totalGoals: 85,
      );

      expect(leaderboard.averageGoalsPerMatch, equals(4.3));
    });
  });

  group('Statistics Repository & Remote Data Source Tests', () {
    late MockStatisticsRemoteDataSource dataSource;
    late StatisticsRepositoryImpl repository;

    setUp(() {
      dataSource = MockStatisticsRemoteDataSource(delay: Duration.zero);
      repository = StatisticsRepositoryImpl(dataSource);
    });

    test(
      'getGroupLeaderboards sorts top scorers and playmakers accurately',
      () async {
        final result = await repository.getGroupLeaderboards();
        expect(result.isSuccess, isTrue);

        final data = result.dataOrNull!;
        expect(data.topScorers.isNotEmpty, isTrue);
        // Top scorer must have highest goals
        expect(
          data.topScorers.first.goals,
          greaterThanOrEqualTo(data.topScorers.last.goals),
        );

        // Top assister must have highest assists
        expect(
          data.topAssisters.first.assists,
          greaterThanOrEqualTo(data.topAssisters.last.assists),
        );

        // Clean sheets leader must be a goalkeeper
        expect(
          data.topCleanSheets.first.position,
          equals(PlayerPosition.goalkeeper),
        );
      },
    );

    test('getPlayerStats returns individual player statistics', () async {
      final result = await repository.getPlayerStats('p1');
      expect(result.isSuccess, isTrue);

      final stats = result.dataOrNull!;
      expect(stats.playerName, equals('مروان سمير'));
      expect(stats.assists, equals(16));
    });
  });

  group('StatisticsBloc State Management Tests', () {
    late MockStatisticsRemoteDataSource dataSource;
    late StatisticsRepositoryImpl repository;
    late GetGroupLeaderboardsUseCase getLeaderboardsUseCase;
    late StatisticsBloc bloc;

    setUp(() {
      dataSource = MockStatisticsRemoteDataSource(delay: Duration.zero);
      repository = StatisticsRepositoryImpl(dataSource);
      getLeaderboardsUseCase = GetGroupLeaderboardsUseCase(repository);

      bloc = StatisticsBloc(
        getGroupLeaderboardsUseCase: getLeaderboardsUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is StatisticsInitial', () {
      expect(bloc.state, isA<StatisticsInitial>());
    });

    test(
      'Emits [StatisticsLoading, StatisticsLoaded] on LoadStatisticsRequested',
      () async {
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<StatisticsLoading>(),
            isA<StatisticsLoaded>()
                .having(
                  (s) => s.leaderboard.allPlayers.length,
                  'players count',
                  greaterThan(0),
                )
                .having(
                  (s) => s.selectedCategory,
                  'default category',
                  StatisticsCategory.goals,
                ),
          ]),
        );

        bloc.add(const LoadStatisticsRequested());
      },
    );

    test(
      'CategoryFilterChanged updates category and switches ranked players list',
      () async {
        // 1. Initial load
        bloc.add(const LoadStatisticsRequested());
        await expectLater(bloc.stream, emitsThrough(isA<StatisticsLoaded>()));

        // 2. Switch to Assists category
        final expectation = expectLater(
          bloc.stream,
          emits(
            isA<StatisticsLoaded>()
                .having(
                  (s) => s.selectedCategory,
                  'category',
                  StatisticsCategory.assists,
                )
                .having(
                  (s) => s.rankedPlayers.first.playerName,
                  'top assister',
                  'مروان سمير',
                ),
          ),
        );

        bloc.add(const CategoryFilterChanged(StatisticsCategory.assists));
        await expectation;
      },
    );
  });
}

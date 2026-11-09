import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/match_status.dart';
import 'package:football_reservation/features/matches/data/datasources/match_remote_data_source.dart';
import 'package:football_reservation/features/matches/data/repositories/match_repository_impl.dart';
import 'package:football_reservation/features/matches/domain/entities/card_event_entity.dart';
import 'package:football_reservation/features/matches/domain/entities/goal_event_entity.dart';
import 'package:football_reservation/features/matches/domain/entities/match_result_entity.dart';
import 'package:football_reservation/features/matches/domain/usecases/cancel_match_registration_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/get_match_by_id_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/get_matches_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/record_match_result_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/register_player_to_match_usecase.dart';
import 'package:football_reservation/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:football_reservation/features/matches/presentation/bloc/matches_event.dart';
import 'package:football_reservation/features/matches/presentation/bloc/matches_state.dart';

void main() {
  group('Match Result Domain Entity Logic Tests', () {
    test('Calculates winner, draw, and total goals properly', () {
      final goals = [
        const GoalEventEntity(
          id: 'g1',
          scorerPlayerId: 'p1',
          scorerName: 'مروان',
          teamName: 'الأخضر',
          minute: 15,
        ),
        const GoalEventEntity(
          id: 'g2',
          scorerPlayerId: 'p2',
          scorerName: 'فهد',
          teamName: 'الأخضر',
          minute: 34,
        ),
        const GoalEventEntity(
          id: 'g3',
          scorerPlayerId: 'p3',
          scorerName: 'سفيان',
          teamName: 'الأبيض',
          minute: 60,
        ),
      ];

      final cards = [
        const CardEventEntity(
          id: 'c1',
          playerId: 'p4',
          playerName: 'عمر',
          isRedCard: false,
          minute: 55,
        ),
      ];

      final result = MatchResultEntity(
        id: 'res_1',
        matchId: 'm1',
        teamAScore: 2,
        teamBScore: 1,
        teamAName: 'الأخضر',
        teamBName: 'الأبيض',
        goals: goals,
        cards: cards,
        manOfTheMatchName: 'مروان',
        isLocked: true,
        recordedAt: DateTime.now(),
      );

      expect(result.totalGoals, equals(3));
      expect(result.isDraw, isFalse);
      expect(result.winnerTeamName, equals('الأخضر'));
      expect(result.isLocked, isTrue);
    });

    test('Identifies Draw result correctly', () {
      final drawResult = MatchResultEntity(
        id: 'res_2',
        matchId: 'm2',
        teamAScore: 2,
        teamBScore: 2,
        teamAName: 'الأخضر',
        teamBName: 'الأبيض',
        recordedAt: DateTime.now(),
      );

      expect(drawResult.isDraw, isTrue);
      expect(drawResult.winnerTeamName, equals('تعادل'));
    });
  });

  group('Match Result Repository & Remote Data Source Tests', () {
    late MockMatchRemoteDataSource dataSource;
    late MatchRepositoryImpl repository;

    setUp(() {
      dataSource = MockMatchRemoteDataSource(delay: Duration.zero);
      repository = MatchRepositoryImpl(dataSource);
    });

    test(
      'recordMatchResult saves result and marks match as completed',
      () async {
        final resultToSave = MatchResultEntity(
          id: 'res_m1',
          matchId: 'm1',
          teamAScore: 4,
          teamBScore: 2,
          teamAName: 'الأخضر',
          teamBName: 'الأبيض',
          manOfTheMatchName: 'مروان سمير',
          isLocked: true,
          recordedAt: DateTime.now(),
        );

        final saveResult = await repository.recordMatchResult(resultToSave);
        expect(saveResult.isSuccess, isTrue);
        expect(saveResult.dataOrNull!.teamAScore, equals(4));

        // Verify match state updated to completed
        final matchResult = await repository.getMatchById('m1');
        expect(matchResult.isSuccess, isTrue);
        final updatedMatch = matchResult.dataOrNull!;
        expect(updatedMatch.status, equals(MatchStatus.completed));
        expect(updatedMatch.result, isNotNull);
        expect(updatedMatch.result!.teamAScore, equals(4));
      },
    );
  });

  group('MatchesBloc Result Recording Tests', () {
    late MockMatchRemoteDataSource dataSource;
    late MatchRepositoryImpl repository;
    late GetMatchesUseCase getMatchesUseCase;
    late GetMatchByIdUseCase getMatchByIdUseCase;
    late RegisterPlayerToMatchUseCase registerUseCase;
    late CancelMatchRegistrationUseCase cancelUseCase;
    late RecordMatchResultUseCase recordResultUseCase;
    late MatchesBloc bloc;

    setUp(() {
      dataSource = MockMatchRemoteDataSource(delay: Duration.zero);
      repository = MatchRepositoryImpl(dataSource);
      getMatchesUseCase = GetMatchesUseCase(repository);
      getMatchByIdUseCase = GetMatchByIdUseCase(repository);
      registerUseCase = RegisterPlayerToMatchUseCase(repository);
      cancelUseCase = CancelMatchRegistrationUseCase(repository);
      recordResultUseCase = RecordMatchResultUseCase(repository);

      bloc = MatchesBloc(
        getMatchesUseCase: getMatchesUseCase,
        getMatchByIdUseCase: getMatchByIdUseCase,
        registerPlayerToMatchUseCase: registerUseCase,
        cancelMatchRegistrationUseCase: cancelUseCase,
        recordMatchResultUseCase: recordResultUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test(
      'Emits updated MatchesLoaded when RecordMatchResultRequested succeeds',
      () async {
        // 1. Initial load
        bloc.add(const LoadMatchesRequested());
        await expectLater(bloc.stream, emitsThrough(isA<MatchesLoaded>()));

        // 2. Record Result
        final result = MatchResultEntity(
          id: 'res_m1',
          matchId: 'm1',
          teamAScore: 3,
          teamBScore: 1,
          teamAName: 'الأخضر',
          teamBName: 'الأبيض',
          recordedAt: DateTime.now(),
        );

        final expectation = expectLater(
          bloc.stream,
          emits(
            isA<MatchesLoaded>()
                .having(
                  (s) => s.selectedMatch?.status,
                  'status',
                  MatchStatus.completed,
                )
                .having(
                  (s) => s.successMessage,
                  'success feedback',
                  contains('تم تثبيت نتيجة المباراة'),
                ),
          ),
        );

        bloc.add(RecordMatchResultRequested(result));
        await expectation;
      },
    );
  });
}

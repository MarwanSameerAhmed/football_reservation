import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/player_position.dart';
import 'package:football_reservation/core/errors/failures.dart';
import 'package:football_reservation/core/utils/result.dart';
import 'package:football_reservation/features/matches/data/datasources/match_remote_data_source.dart';
import 'package:football_reservation/features/matches/data/repositories/match_repository_impl.dart';
import 'package:football_reservation/features/matches/domain/entities/match_entity.dart';
import 'package:football_reservation/features/matches/domain/usecases/cancel_match_registration_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/get_match_by_id_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/get_matches_usecase.dart';
import 'package:football_reservation/features/matches/domain/usecases/register_player_to_match_usecase.dart';
import 'package:football_reservation/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:football_reservation/features/matches/presentation/bloc/matches_event.dart';
import 'package:football_reservation/features/matches/presentation/bloc/matches_state.dart';

void main() {
  group('Matches & RSVP Attendance Domain Rules', () {
    late MockMatchRemoteDataSource dataSource;
    late MatchRepositoryImpl repository;
    late GetMatchesUseCase getMatchesUseCase;
    late RegisterPlayerToMatchUseCase registerUseCase;
    late CancelMatchRegistrationUseCase cancelUseCase;

    setUp(() {
      dataSource = MockMatchRemoteDataSource();
      repository = MatchRepositoryImpl(dataSource);
      getMatchesUseCase = GetMatchesUseCase(repository);
      registerUseCase = RegisterPlayerToMatchUseCase(repository);
      cancelUseCase = CancelMatchRegistrationUseCase(repository);
    });

    test('getMatches returns seeded matches list', () async {
      final result = await getMatchesUseCase();
      expect(result, isA<Success<List<MatchEntity>>>());
      final matches = (result as Success<List<MatchEntity>>).data;
      expect(matches.length, greaterThanOrEqualTo(2));
    });

    test(
      'registerPlayer adds player to confirmed squad when spots are open',
      () async {
        final result = await registerUseCase(
          matchId: 'm1',
          playerId: 'new_player_101',
          playerName: 'حسام حسن',
          position: PlayerPosition.forward,
        );

        expect(result, isA<Success<MatchEntity>>());
        final match = (result as Success<MatchEntity>).data;
        expect(
          match.confirmedPlayers.any((p) => p.playerId == 'new_player_101'),
          isTrue,
        );
      },
    );

    test(
      'registerPlayer prevents duplicate registration in the same match',
      () async {
        // p1 is already registered in m1
        final result = await registerUseCase(
          matchId: 'm1',
          playerId: 'p1',
          playerName: 'مروان سمير',
          position: PlayerPosition.midfielder,
        );

        expect(result, isA<FailureResult<MatchEntity>>());
        final failure = (result as FailureResult<MatchEntity>).failure;
        expect(failure, isA<ValidationFailure>());
      },
    );

    test(
      'registerPlayer automatically assigns player to Waiting List when squad is full',
      () async {
        // m2 is already full (10/10 confirmed)
        final result = await registerUseCase(
          matchId: 'm2',
          playerId: 'waiting_player_99',
          playerName: 'طارق حامد',
          position: PlayerPosition.midfielder,
        );

        expect(result, isA<Success<MatchEntity>>());
        final match = (result as Success<MatchEntity>).data;
        expect(
          match.waitingList.any((p) => p.playerId == 'waiting_player_99'),
          isTrue,
        );
        final waitingReg = match.waitingList.firstWhere(
          (p) => p.playerId == 'waiting_player_99',
        );
        expect(waitingReg.queuePosition, 2); // m2 already had 1 waiting player
      },
    );

    test(
      'cancelRegistration automatically promotes #1 waiting player when confirmed player cancels',
      () async {
        // In m2: 'p_conf_0' is confirmed, 'p_wait_1' (كابتن ماجد) is waiting #1
        final cancelResult = await cancelUseCase(
          matchId: 'm2',
          playerId: 'p_conf_0',
        );

        expect(cancelResult, isA<Success<MatchEntity>>());
        final updatedMatch = (cancelResult as Success<MatchEntity>).data;

        // 'p_conf_0' was removed
        expect(
          updatedMatch.confirmedPlayers.any((p) => p.playerId == 'p_conf_0'),
          isFalse,
        );

        // 'p_wait_1' (كابتن ماجد) was automatically promoted to confirmed squad!
        expect(
          updatedMatch.confirmedPlayers.any((p) => p.playerId == 'p_wait_1'),
          isTrue,
        );
        final promoted = updatedMatch.confirmedPlayers.firstWhere(
          (p) => p.playerId == 'p_wait_1',
        );
        expect(promoted.isConfirmed, isTrue);

        // Waiting list is now empty!
        expect(updatedMatch.waitingList, isEmpty);
      },
    );
  });

  group('MatchesBloc State Transitions', () {
    late MockMatchRemoteDataSource dataSource;
    late MatchRepositoryImpl repository;
    late GetMatchesUseCase getMatchesUseCase;
    late GetMatchByIdUseCase getMatchByIdUseCase;
    late RegisterPlayerToMatchUseCase registerUseCase;
    late CancelMatchRegistrationUseCase cancelUseCase;
    late MatchesBloc matchesBloc;

    setUp(() {
      dataSource = MockMatchRemoteDataSource();
      repository = MatchRepositoryImpl(dataSource);
      getMatchesUseCase = GetMatchesUseCase(repository);
      getMatchByIdUseCase = GetMatchByIdUseCase(repository);
      registerUseCase = RegisterPlayerToMatchUseCase(repository);
      cancelUseCase = CancelMatchRegistrationUseCase(repository);

      matchesBloc = MatchesBloc(
        getMatchesUseCase: getMatchesUseCase,
        getMatchByIdUseCase: getMatchByIdUseCase,
        registerPlayerToMatchUseCase: registerUseCase,
        cancelMatchRegistrationUseCase: cancelUseCase,
      );
    });

    tearDown(() {
      matchesBloc.close();
    });

    test('Initial state is MatchesInitial', () {
      expect(matchesBloc.state, const MatchesInitial());
    });

    test(
      'Emits [MatchesLoading, MatchesLoaded] on LoadMatchesRequested',
      () async {
        final expected = [
          const MatchesLoading(),
          isA<MatchesLoaded>().having(
            (s) => s.matches.length,
            'match count',
            2,
          ),
        ];

        expectLater(matchesBloc.stream, emitsInOrder(expected));
        matchesBloc.add(const LoadMatchesRequested());
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/poll_type.dart';
import 'package:football_reservation/features/polls/data/datasources/poll_remote_data_source.dart';
import 'package:football_reservation/features/polls/data/repositories/poll_repository_impl.dart';
import 'package:football_reservation/features/polls/domain/entities/poll_entity.dart';
import 'package:football_reservation/features/polls/domain/entities/poll_option_entity.dart';
import 'package:football_reservation/features/polls/domain/usecases/close_poll_usecase.dart';
import 'package:football_reservation/features/polls/domain/usecases/create_poll_usecase.dart';
import 'package:football_reservation/features/polls/domain/usecases/get_poll_by_id_usecase.dart';
import 'package:football_reservation/features/polls/domain/usecases/get_polls_usecase.dart';
import 'package:football_reservation/features/polls/domain/usecases/vote_poll_usecase.dart';
import 'package:football_reservation/features/polls/presentation/bloc/polls_bloc.dart';
import 'package:football_reservation/features/polls/presentation/bloc/polls_event.dart';
import 'package:football_reservation/features/polls/presentation/bloc/polls_state.dart';

void main() {
  group('Poll Domain Entities Logic Tests', () {
    test('Calculates total votes and percentages accurately', () {
      final opt1 = const PollOptionEntity(
        id: 'opt_1',
        text: 'الجمعة 8 م',
        voterUserIds: ['u1', 'u2', 'u3'],
      );
      final opt2 = const PollOptionEntity(
        id: 'opt_2',
        text: 'السبت 8 م',
        voterUserIds: ['u4'],
      );

      final poll = PollEntity(
        id: 'poll_1',
        title: 'موعد المباراة',
        type: PollType.matchScheduling,
        creatorId: 'admin_1',
        closesAt: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        options: [opt1, opt2],
      );

      expect(poll.totalVotes, equals(4));
      expect(poll.optionPercentage(opt1), equals(75.0));
      expect(poll.optionPercentage(opt2), equals(25.0));
      expect(poll.hasUserVoted('u1'), isTrue);
      expect(poll.hasUserVoted('u99'), isFalse);
      expect(poll.getUserVotedOptionId('u1'), equals('opt_1'));
      expect(poll.winningOption?.id, equals('opt_1'));
    });

    test('Poll expiration detects deadline correctly', () {
      final expiredPoll = PollEntity(
        id: 'poll_exp',
        title: 'استطلاع قديم',
        type: PollType.general,
        creatorId: 'admin_1',
        closesAt: DateTime.now().subtract(const Duration(minutes: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        options: const [],
      );

      expect(expiredPoll.hasExpired, isTrue);
      expect(expiredPoll.isActive, isFalse);
    });
  });

  group('Poll Repository & Remote Data Source Tests', () {
    late MockPollRemoteDataSource dataSource;
    late PollRepositoryImpl repository;

    setUp(() {
      dataSource = MockPollRemoteDataSource(delay: Duration.zero);
      repository = PollRepositoryImpl(dataSource);
    });

    test('getPolls retrieves pre-seeded scheduling and MOTM polls', () async {
      final result = await repository.getPolls();
      expect(result.isSuccess, isTrue);
      final polls = result.dataOrNull!;
      expect(polls.length, greaterThanOrEqualTo(2));
      expect(polls.any((p) => p.type == PollType.matchScheduling), isTrue);
      expect(polls.any((p) => p.type == PollType.manOfTheMatch), isTrue);
    });

    test(
      'vote registers vote and switches previous choice in single-choice poll',
      () async {
        const pollId = 'poll_schedule_1';
        const userId = 'voter_tester_1';

        // Vote for Option 1
        final vote1Result = await repository.vote(
          pollId: pollId,
          optionId: 'opt_1',
          userId: userId,
        );
        expect(vote1Result.isSuccess, isTrue);
        var poll = vote1Result.dataOrNull!;
        expect(
          poll.options.firstWhere((o) => o.id == 'opt_1').hasVoted(userId),
          isTrue,
        );

        // Now switch vote to Option 2
        final vote2Result = await repository.vote(
          pollId: pollId,
          optionId: 'opt_2',
          userId: userId,
        );
        expect(vote2Result.isSuccess, isTrue);
        poll = vote2Result.dataOrNull!;
        // Option 1 must no longer contain this user
        expect(
          poll.options.firstWhere((o) => o.id == 'opt_1').hasVoted(userId),
          isFalse,
        );
        // Option 2 must contain this user
        expect(
          poll.options.firstWhere((o) => o.id == 'opt_2').hasVoted(userId),
          isTrue,
        );
      },
    );

    test('closePoll locks the poll from further voting', () async {
      const pollId = 'poll_schedule_1';
      final closeResult = await repository.closePoll(pollId);
      expect(closeResult.isSuccess, isTrue);
      expect(closeResult.dataOrNull!.isClosed, isTrue);

      // Attempting to vote on closed poll fails
      final voteAttempt = await repository.vote(
        pollId: pollId,
        optionId: 'opt_1',
        userId: 'some_user',
      );
      expect(voteAttempt.isFailure, isTrue);
    });
  });

  group('PollsBloc State Management Tests', () {
    late MockPollRemoteDataSource dataSource;
    late PollRepositoryImpl repository;
    late GetPollsUseCase getPollsUseCase;
    late GetPollByIdUseCase getPollByIdUseCase;
    late CreatePollUseCase createPollUseCase;
    late VotePollUseCase votePollUseCase;
    late ClosePollUseCase closePollUseCase;
    late PollsBloc bloc;

    setUp(() {
      dataSource = MockPollRemoteDataSource(delay: Duration.zero);
      repository = PollRepositoryImpl(dataSource);
      getPollsUseCase = GetPollsUseCase(repository);
      getPollByIdUseCase = GetPollByIdUseCase(repository);
      createPollUseCase = CreatePollUseCase(repository);
      votePollUseCase = VotePollUseCase(repository);
      closePollUseCase = ClosePollUseCase(repository);

      bloc = PollsBloc(
        getPollsUseCase: getPollsUseCase,
        getPollByIdUseCase: getPollByIdUseCase,
        createPollUseCase: createPollUseCase,
        votePollUseCase: votePollUseCase,
        closePollUseCase: closePollUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is PollsInitial', () {
      expect(bloc.state, isA<PollsInitial>());
    });

    test('Emits [PollsLoading, PollsLoaded] on LoadPollsRequested', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PollsLoading>(),
          isA<PollsLoaded>().having(
            (s) => s.polls.length,
            'polls count',
            greaterThan(0),
          ),
        ]),
      );

      bloc.add(const LoadPollsRequested());
    });

    test(
      'Emits updated PollsLoaded with feedback message on CastVoteRequested',
      () async {
        // First load polls
        bloc.add(const LoadPollsRequested());
        await expectLater(bloc.stream, emitsThrough(isA<PollsLoaded>()));

        // Cast vote
        final voteExpectation = expectLater(
          bloc.stream,
          emitsThrough(
            isA<PollsLoaded>().having(
              (s) => s.feedbackMessage,
              'feedback',
              'تم تسجيل صوتك بنجاح ⚽',
            ),
          ),
        );

        bloc.add(
          const CastVoteRequested(
            pollId: 'poll_schedule_1',
            optionId: 'opt_1',
            userId: 'test_user_bloc',
          ),
        );

        await voteExpectation;
      },
    );
  });
}

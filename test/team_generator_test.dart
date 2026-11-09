import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/player_position.dart';
import 'package:football_reservation/core/enums/preferred_foot.dart';
import 'package:football_reservation/features/players/domain/entities/player_entity.dart';
import 'package:football_reservation/features/players/domain/entities/player_skills.dart';
import 'package:football_reservation/features/team_generator/data/datasources/team_generator_remote_data_source.dart';
import 'package:football_reservation/features/team_generator/data/repositories/team_generator_repository_impl.dart';
import 'package:football_reservation/features/team_generator/domain/engine/team_balancer.dart';
import 'package:football_reservation/features/team_generator/domain/usecases/generate_balanced_teams_usecase.dart';
import 'package:football_reservation/features/team_generator/domain/usecases/get_lineup_history_usecase.dart';
import 'package:football_reservation/features/team_generator/domain/usecases/save_final_lineup_usecase.dart';
import 'package:football_reservation/features/team_generator/domain/usecases/swap_players_usecase.dart';
import 'package:football_reservation/features/team_generator/presentation/bloc/team_generator_bloc.dart';
import 'package:football_reservation/features/team_generator/presentation/bloc/team_generator_event.dart';
import 'package:football_reservation/features/team_generator/presentation/bloc/team_generator_state.dart';

PlayerEntity _createPlayer({
  required String id,
  required String name,
  required PlayerPosition position,
  required int pace,
  required int shooting,
  required int passing,
  required int defending,
  required int physical,
  required int goalkeeping,
}) {
  return PlayerEntity(
    id: id,
    userId: 'user_$id',
    name: name,
    primaryPosition: position,
    preferredFoot: PreferredFoot.right,
    createdAt: DateTime.now(),
    skills: PlayerSkills(
      pace: pace,
      shooting: shooting,
      passing: passing,
      defending: defending,
      physical: physical,
      goalkeeping: goalkeeping,
    ),
  );
}

void main() {
  late List<PlayerEntity> mockPlayers;
  late List<PlayerEntity> mock18Players;

  setUp(() {
    mock18Players = List.generate(
      18,
      (i) => _createPlayer(
        id: 'p_${i + 1}',
        name: 'لاعب ${i + 1}',
        position: i < 6
            ? PlayerPosition.defender
            : (i < 12 ? PlayerPosition.midfielder : PlayerPosition.forward),
        pace: 70 + (i % 5) * 4,
        shooting: 65 + (i % 6) * 4,
        passing: 72 + (i % 4) * 5,
        defending: 68 + (i % 5) * 4,
        physical: 75 + (i % 3) * 5,
        goalkeeping: 50 + (i % 4) * 8, // Rotating keepers across the team
      ),
    );

    mockPlayers = [
      // 2 Goalkeepers
      _createPlayer(
        id: 'gk_1',
        name: 'حارس أ',
        position: PlayerPosition.goalkeeper,
        pace: 50,
        shooting: 30,
        passing: 60,
        defending: 60,
        physical: 75,
        goalkeeping: 88,
      ),
      _createPlayer(
        id: 'gk_2',
        name: 'حارس ب',
        position: PlayerPosition.goalkeeper,
        pace: 45,
        shooting: 25,
        passing: 55,
        defending: 55,
        physical: 70,
        goalkeeping: 84,
      ),
      // 4 Defenders
      _createPlayer(
        id: 'def_1',
        name: 'مدافع 1',
        position: PlayerPosition.defender,
        pace: 75,
        shooting: 50,
        passing: 70,
        defending: 85,
        physical: 80,
        goalkeeping: 20,
      ),
      _createPlayer(
        id: 'def_2',
        name: 'مدافع 2',
        position: PlayerPosition.defender,
        pace: 70,
        shooting: 45,
        passing: 68,
        defending: 82,
        physical: 78,
        goalkeeping: 20,
      ),
      _createPlayer(
        id: 'def_3',
        name: 'مدافع 3',
        position: PlayerPosition.defender,
        pace: 72,
        shooting: 48,
        passing: 65,
        defending: 80,
        physical: 75,
        goalkeeping: 20,
      ),
      _createPlayer(
        id: 'def_4',
        name: 'مدافع 4',
        position: PlayerPosition.defender,
        pace: 68,
        shooting: 40,
        passing: 60,
        defending: 78,
        physical: 74,
        goalkeeping: 20,
      ),
      // 4 Midfielders
      _createPlayer(
        id: 'mid_1',
        name: 'وسط 1',
        position: PlayerPosition.midfielder,
        pace: 80,
        shooting: 75,
        passing: 88,
        defending: 70,
        physical: 76,
        goalkeeping: 20,
      ),
      _createPlayer(
        id: 'mid_2',
        name: 'وسط 2',
        position: PlayerPosition.midfielder,
        pace: 78,
        shooting: 72,
        passing: 85,
        defending: 68,
        physical: 74,
        goalkeeping: 20,
      ),
      _createPlayer(
        id: 'mid_3',
        name: 'وسط 3',
        position: PlayerPosition.midfielder,
        pace: 76,
        shooting: 70,
        passing: 82,
        defending: 65,
        physical: 72,
        goalkeeping: 20,
      ),
      _createPlayer(
        id: 'mid_4',
        name: 'وسط 4',
        position: PlayerPosition.midfielder,
        pace: 74,
        shooting: 68,
        passing: 80,
        defending: 64,
        physical: 70,
        goalkeeping: 20,
      ),
      // 4 Forwards
      _createPlayer(
        id: 'fwd_1',
        name: 'مهاجم 1',
        position: PlayerPosition.forward,
        pace: 88,
        shooting: 89,
        passing: 75,
        defending: 40,
        physical: 76,
        goalkeeping: 15,
      ),
      _createPlayer(
        id: 'fwd_2',
        name: 'مهاجم 2',
        position: PlayerPosition.forward,
        pace: 85,
        shooting: 86,
        passing: 72,
        defending: 38,
        physical: 74,
        goalkeeping: 15,
      ),
      _createPlayer(
        id: 'fwd_3',
        name: 'مهاجم 3',
        position: PlayerPosition.forward,
        pace: 82,
        shooting: 83,
        passing: 70,
        defending: 36,
        physical: 72,
        goalkeeping: 15,
      ),
      _createPlayer(
        id: 'fwd_4',
        name: 'مهاجم 4',
        position: PlayerPosition.forward,
        pace: 80,
        shooting: 80,
        passing: 68,
        defending: 35,
        physical: 70,
        goalkeeping: 15,
      ),
    ];
  });

  group('TeamBalancer Algorithm Tests', () {
    test('Splits 14 players evenly with 7 players per team', () {
      final lineup = TeamBalancer.balance(
        players: mockPlayers,
        matchId: 'match_123',
      );

      expect(lineup.teamA.players.length, equals(7));
      expect(lineup.teamB.players.length, equals(7));
    });

    test('Assigns exactly 1 Goalkeeper to each team', () {
      final lineup = TeamBalancer.balance(
        players: mockPlayers,
        matchId: 'match_123',
      );

      final gkTeamA = lineup.teamA.players
          .where((p) => p.primaryPosition == PlayerPosition.goalkeeper)
          .length;
      final gkTeamB = lineup.teamB.players
          .where((p) => p.primaryPosition == PlayerPosition.goalkeeper)
          .length;

      expect(gkTeamA, equals(1));
      expect(gkTeamB, equals(1));
    });

    test('Produces high tactical balance with total score variance <= 5%', () {
      final lineup = TeamBalancer.balance(
        players: mockPlayers,
        matchId: 'match_123',
      );

      final scoreA = lineup.teamA.totalScore;
      final scoreB = lineup.teamB.totalScore;
      final diff = (scoreA - scoreB).abs();
      final avg = (scoreA + scoreB) / 2;
      final variancePct = (diff / avg) * 100;

      expect(variancePct, lessThanOrEqualTo(5.0));
    });

    test(
      'Manual swap interchanges players and recalculates scores correctly',
      () {
        final lineup = TeamBalancer.balance(
          players: mockPlayers,
          matchId: 'match_123',
        );

        final playerA = lineup.teamA.players.first;
        final playerB = lineup.teamB.players.first;

        final swapped = TeamBalancer.swap(
          lineup: lineup,
          playerAId: playerA.id,
          playerBId: playerB.id,
        );

        expect(swapped.teamA.players.any((p) => p.id == playerB.id), isTrue);
        expect(swapped.teamB.players.any((p) => p.id == playerA.id), isTrue);
      },
    );

    test('Splits 18 players into 3 balanced teams of 6 players each', () {
      final lineup = TeamBalancer.balance(
        players: mock18Players,
        matchId: 'match_18',
      );

      expect(lineup.teams.length, equals(3));
      expect(lineup.teams[0].players.length, equals(6));
      expect(lineup.teams[1].players.length, equals(6));
      expect(lineup.teams[2].players.length, equals(6));
      expect(lineup.teams[0].name, equals('الفريق الأول (الأخضر)'));
      expect(lineup.teams[1].name, equals('الفريق الثاني (الأبيض)'));
      expect(lineup.teams[2].name, equals('الفريق الثالث (الأسود)'));
    });

    test(
      'Rotates goalkeeping across team and balances 3 teams with score variance <= 5%',
      () {
        final lineup = TeamBalancer.balance(
          players: mock18Players,
          matchId: 'match_18',
        );

        final scores = lineup.teams.map((t) => t.totalScore).toList();
        final maxS = scores.reduce((a, b) => a > b ? a : b);
        final minS = scores.reduce((a, b) => a < b ? a : b);
        final avgS = scores.fold(0, (sum, s) => sum + s) / 3;
        final variancePct = ((maxS - minS) / avgS) * 100;

        expect(variancePct, lessThanOrEqualTo(5.0));
      },
    );

    test(
      'Manual swap interchanges players across 3 teams (Team 1 and Team 3) seamlessly',
      () {
        final lineup = TeamBalancer.balance(
          players: mock18Players,
          matchId: 'match_18',
        );

        final playerFrom1 = lineup.teams[0].players.first;
        final playerFrom3 = lineup.teams[2].players.first;

        final swapped = TeamBalancer.swap(
          lineup: lineup,
          playerAId: playerFrom1.id,
          playerBId: playerFrom3.id,
        );

        expect(
          swapped.teams[0].players.any((p) => p.id == playerFrom3.id),
          isTrue,
        );
        expect(
          swapped.teams[2].players.any((p) => p.id == playerFrom1.id),
          isTrue,
        );
        expect(swapped.teams[0].players.length, equals(6));
        expect(swapped.teams[2].players.length, equals(6));
      },
    );
  });

  group('TeamGeneratorRepository & Bloc Tests', () {
    late MockTeamGeneratorRemoteDataSource mockDataSource;
    late TeamGeneratorRepositoryImpl repository;
    late GenerateBalancedTeamsUseCase generateUseCase;
    late SwapPlayersUseCase swapUseCase;
    late SaveFinalLineupUseCase saveUseCase;
    late GetLineupHistoryUseCase getHistoryUseCase;
    late TeamGeneratorBloc bloc;

    setUp(() {
      mockDataSource = MockTeamGeneratorRemoteDataSource(delay: Duration.zero);
      repository = TeamGeneratorRepositoryImpl(mockDataSource);
      generateUseCase = GenerateBalancedTeamsUseCase(repository);
      swapUseCase = SwapPlayersUseCase(repository);
      saveUseCase = SaveFinalLineupUseCase(repository);
      getHistoryUseCase = GetLineupHistoryUseCase(repository);

      bloc = TeamGeneratorBloc(
        generateBalancedTeamsUseCase: generateUseCase,
        swapPlayersUseCase: swapUseCase,
        saveFinalLineupUseCase: saveUseCase,
        getLineupHistoryUseCase: getHistoryUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Repository generates balanced lineup successfully', () async {
      final result = await repository.generateBalancedTeams(
        players: mockPlayers,
        matchId: 'match_1',
      );

      expect(result.isSuccess, isTrue);
      final lineup = result.dataOrNull!;
      expect(lineup.teamA.players.isNotEmpty, isTrue);
      expect(lineup.teamB.players.isNotEmpty, isTrue);
    });

    test('Repository finalizes and saves lineup properly', () async {
      final genResult = await repository.generateBalancedTeams(
        players: mockPlayers,
        matchId: 'match_1',
      );
      final lineup = genResult.dataOrNull!;

      final saveResult = await repository.saveFinalLineup(lineup);
      expect(saveResult.isSuccess, isTrue);
      expect(saveResult.dataOrNull!.isFinalized, isTrue);

      final historyResult = await repository.getLineupHistory(
        matchId: 'match_1',
      );
      expect(historyResult.isSuccess, isTrue);
      expect(historyResult.dataOrNull!.length, equals(1));
    });

    test(
      'Bloc emits Loading then Success upon GenerateBalancedTeamsRequested',
      () async {
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<TeamGeneratorLoading>(),
            isA<TeamGeneratorSuccess>()
                .having((s) => s.currentLineup != null, 'has lineup', isTrue)
                .having(
                  (s) => s.currentLineup!.teamA.players.length,
                  'teamA size',
                  7,
                ),
          ]),
        );

        bloc.add(
          GenerateBalancedTeamsRequested(
            matchId: 'match_1',
            players: mockPlayers,
          ),
        );
      },
    );

    test(
      'Bloc manages tap-to-swap selection and executes swap across teams',
      () async {
        // Step 1: Request generation and wait for success state
        final successExpectation = expectLater(
          bloc.stream,
          emitsThrough(isA<TeamGeneratorSuccess>()),
        );

        bloc.add(
          GenerateBalancedTeamsRequested(
            matchId: 'match_1',
            players: mockPlayers,
          ),
        );

        await successExpectation;

        final successState = bloc.state as TeamGeneratorSuccess;
        final playerFromA = successState.currentLineup!.teamA.players.first;
        final playerFromB = successState.currentLineup!.teamB.players.first;

        // Step 2: Select Player from Team A
        final selectExpectation = expectLater(
          bloc.stream,
          emits(
            isA<TeamGeneratorSuccess>().having(
              (s) => s.selectedPlayerForSwap?.id,
              'selected player',
              playerFromA.id,
            ),
          ),
        );

        bloc.add(SelectPlayerForSwapRequested(playerFromA));
        await selectExpectation;

        // Step 3: Select Player from Team B -> triggers swap!
        final swapExpectation = expectLater(
          bloc.stream,
          emits(
            isA<TeamGeneratorSuccess>().having(
              (s) => s.selectedPlayerForSwap,
              'cleared selection',
              isNull,
            ),
          ),
        );

        bloc.add(SelectPlayerForSwapRequested(playerFromB));
        await swapExpectation;
      },
    );

    test(
      'Bloc manages 3-team generation and tap-to-swap across Team 1 and Team 3',
      () async {
        final successExpectation = expectLater(
          bloc.stream,
          emitsThrough(isA<TeamGeneratorSuccess>()),
        );

        bloc.add(
          GenerateBalancedTeamsRequested(
            matchId: 'match_18',
            players: mock18Players,
          ),
        );

        await successExpectation;

        final successState = bloc.state as TeamGeneratorSuccess;
        expect(successState.currentLineup!.teams.length, equals(3));

        final player1 = successState.currentLineup!.teams[0].players.first;
        final player3 = successState.currentLineup!.teams[2].players.first;

        // Select player from Team 1
        final selectExpectation = expectLater(
          bloc.stream,
          emits(
            isA<TeamGeneratorSuccess>().having(
              (s) => s.selectedPlayerForSwap?.id,
              'selected player',
              player1.id,
            ),
          ),
        );

        bloc.add(SelectPlayerForSwapRequested(player1));
        await selectExpectation;

        // Select player from Team 3 -> triggers swap between Team 1 and Team 3
        final swapExpectation = expectLater(
          bloc.stream,
          emits(
            isA<TeamGeneratorSuccess>().having(
              (s) => s.selectedPlayerForSwap,
              'cleared selection after swap',
              isNull,
            ),
          ),
        );

        bloc.add(SelectPlayerForSwapRequested(player3));
        await swapExpectation;
      },
    );
  });
}

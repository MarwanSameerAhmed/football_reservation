import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/player_position.dart';
import 'package:football_reservation/core/enums/user_role.dart';
import 'package:football_reservation/core/errors/failures.dart';
import 'package:football_reservation/core/utils/result.dart';
import 'package:football_reservation/features/players/data/datasources/player_remote_data_source.dart';
import 'package:football_reservation/features/players/data/repositories/player_repository_impl.dart';
import 'package:football_reservation/features/players/domain/entities/player_entity.dart';
import 'package:football_reservation/features/players/domain/entities/player_skills.dart';
import 'package:football_reservation/features/players/domain/usecases/get_players_usecase.dart';
import 'package:football_reservation/features/players/domain/usecases/update_player_skills_usecase.dart';
import 'package:football_reservation/features/players/presentation/bloc/players_bloc.dart';
import 'package:football_reservation/features/players/presentation/bloc/players_event.dart';
import 'package:football_reservation/features/players/presentation/bloc/players_state.dart';

void main() {
  group('PlayerSkills Domain Entity Tests', () {
    test('Calculates overallScore and starsRating accurately', () {
      const skills = PlayerSkills(
        pace: 90,
        shooting: 80,
        passing: 85,
        defending: 75,
        physical: 80,
      );

      // (90 + 80 + 85 + 75 + 80) / 5 = 410 / 5 = 82
      expect(skills.overallScore, 82);
      // 82 / 20 = 4.1 stars
      expect(skills.starsRating, 4.1);
    });
  });

  group('Player Repository & Security Rule Verification', () {
    late MockPlayerRemoteDataSource dataSource;
    late PlayerRepositoryImpl repository;
    late GetPlayersUseCase getPlayersUseCase;
    late UpdatePlayerSkillsUseCase updateSkillsUseCase;

    setUp(() {
      dataSource = MockPlayerRemoteDataSource();
      repository = PlayerRepositoryImpl(dataSource);
      getPlayersUseCase = GetPlayersUseCase(repository);
      updateSkillsUseCase = UpdatePlayerSkillsUseCase(repository);
    });

    test('getPlayers returns list of pre-seeded squad players', () async {
      final result = await getPlayersUseCase();
      expect(result, isA<Success<List<PlayerEntity>>>());
      final players = (result as Success<List<PlayerEntity>>).data;
      expect(players.length, greaterThanOrEqualTo(6));
    });

    test('getPlayers filters correctly by position', () async {
      final result = await getPlayersUseCase(
        positionFilter: PlayerPosition.goalkeeper,
      );
      expect(result, isA<Success<List<PlayerEntity>>>());
      final gks = (result as Success<List<PlayerEntity>>).data;
      expect(
        gks.every((p) => p.primaryPosition == PlayerPosition.goalkeeper),
        isTrue,
      );
    });

    test('getPlayers searches accurately by name and nickname', () async {
      final result = await getPlayersUseCase(searchQuery: 'الدوسري');
      expect(result, isA<Success<List<PlayerEntity>>>());
      final players = (result as Success<List<PlayerEntity>>).data;
      expect(players.length, 1);
      expect(players.first.name, 'فهد الدوسري');
    });

    test('SECURITY RULE: Admin CAN update player technical skills', () async {
      const newSkills = PlayerSkills(
        pace: 95,
        shooting: 90,
        passing: 95,
        defending: 85,
        physical: 90,
      );

      final result = await updateSkillsUseCase(
        playerId: 'p1',
        skills: newSkills,
        updaterRole: UserRole.admin,
      );

      expect(result, isA<Success<PlayerEntity>>());
      final updated = (result as Success<PlayerEntity>).data;
      expect(updated.skills.pace, 95);
      expect(updated.skills.overallScore, 91);
    });

    test(
      'SECURITY RULE: Regular Player CANNOT update skills and receives PermissionDeniedFailure',
      () async {
        const illegalSkills = PlayerSkills(
          pace: 99,
          shooting: 99,
          passing: 99,
          defending: 99,
          physical: 99,
        );

        final result = await updateSkillsUseCase(
          playerId: 'p1',
          skills: illegalSkills,
          updaterRole: UserRole.player,
        );

        expect(result, isA<FailureResult<PlayerEntity>>());
        final failure = (result as FailureResult<PlayerEntity>).failure;
        expect(failure, isA<PermissionDeniedFailure>());
      },
    );
  });

  group('PlayersBloc State Management', () {
    late MockPlayerRemoteDataSource dataSource;
    late PlayerRepositoryImpl repository;
    late GetPlayersUseCase getPlayersUseCase;
    late UpdatePlayerSkillsUseCase updateSkillsUseCase;
    late PlayersBloc playersBloc;

    setUp(() {
      dataSource = MockPlayerRemoteDataSource();
      repository = PlayerRepositoryImpl(dataSource);
      getPlayersUseCase = GetPlayersUseCase(repository);
      updateSkillsUseCase = UpdatePlayerSkillsUseCase(repository);

      playersBloc = PlayersBloc(
        getPlayersUseCase: getPlayersUseCase,
        updatePlayerSkillsUseCase: updateSkillsUseCase,
      );
    });

    tearDown(() {
      playersBloc.close();
    });

    test('Initial state is PlayersInitial', () {
      expect(playersBloc.state, const PlayersInitial());
    });

    test(
      'Emits [PlayersLoading, PlayersLoaded] on LoadPlayersRequested',
      () async {
        final expected = [
          const PlayersLoading(),
          isA<PlayersLoaded>().having(
            (s) => s.allPlayers.length,
            'total count',
            18,
          ),
        ];

        expectLater(playersBloc.stream, emitsInOrder(expected));
        playersBloc.add(const LoadPlayersRequested());
      },
    );
  });
}

import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../domain/entities/team_lineup_entity.dart';
import '../../domain/repositories/team_generator_repository.dart';
import '../datasources/team_generator_remote_data_source.dart';

class TeamGeneratorRepositoryImpl implements TeamGeneratorRepository {
  final TeamGeneratorRemoteDataSource _remoteDataSource;

  const TeamGeneratorRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<TeamLineupEntity>> generateBalancedTeams({
    required List<PlayerEntity> players,
    required String matchId,
  }) async {
    try {
      final lineup = await _remoteDataSource.generateBalancedTeams(
        players: players,
        matchId: matchId,
      );
      return Success(lineup);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<TeamLineupEntity>> swapPlayers({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  }) async {
    try {
      final swapped = await _remoteDataSource.swapPlayers(
        lineup: lineup,
        playerAId: playerAId,
        playerBId: playerBId,
      );
      return Success(swapped);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<TeamLineupEntity>> saveFinalLineup(
    TeamLineupEntity lineup,
  ) async {
    try {
      final saved = await _remoteDataSource.saveFinalLineup(lineup);
      return Success(saved);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TeamLineupEntity>>> getLineupHistory({
    String? matchId,
  }) async {
    try {
      final history = await _remoteDataSource.getLineupHistory(
        matchId: matchId,
      );
      return Success(history);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}

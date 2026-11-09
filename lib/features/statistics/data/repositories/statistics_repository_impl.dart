import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/group_leaderboard_entity.dart';
import '../../domain/entities/player_stats_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_data_source.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource _remoteDataSource;

  const StatisticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<GroupLeaderboardEntity>> getGroupLeaderboards() async {
    try {
      final leaderboards = await _remoteDataSource.getGroupLeaderboards();
      return Success(leaderboards);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PlayerStatsEntity>> getPlayerStats(String playerId) async {
    try {
      final stats = await _remoteDataSource.getPlayerStats(playerId);
      return Success(stats);
    } on AppException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}

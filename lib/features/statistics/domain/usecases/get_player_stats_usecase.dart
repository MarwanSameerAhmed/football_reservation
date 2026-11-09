import '../../../../core/utils/result.dart';
import '../entities/player_stats_entity.dart';
import '../repositories/statistics_repository.dart';

class GetPlayerStatsUseCase {
  final StatisticsRepository _repository;

  const GetPlayerStatsUseCase(this._repository);

  Future<Result<PlayerStatsEntity>> call(String playerId) {
    return _repository.getPlayerStats(playerId);
  }
}

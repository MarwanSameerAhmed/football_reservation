import '../../../../core/utils/result.dart';
import '../entities/group_leaderboard_entity.dart';
import '../repositories/statistics_repository.dart';

class GetGroupLeaderboardsUseCase {
  final StatisticsRepository _repository;

  const GetGroupLeaderboardsUseCase(this._repository);

  Future<Result<GroupLeaderboardEntity>> call() {
    return _repository.getGroupLeaderboards();
  }
}

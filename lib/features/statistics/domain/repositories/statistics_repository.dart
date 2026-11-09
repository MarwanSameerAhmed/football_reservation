import '../../../../core/utils/result.dart';
import '../entities/group_leaderboard_entity.dart';
import '../entities/player_stats_entity.dart';

abstract class StatisticsRepository {
  Future<Result<GroupLeaderboardEntity>> getGroupLeaderboards();

  Future<Result<PlayerStatsEntity>> getPlayerStats(String playerId);
}

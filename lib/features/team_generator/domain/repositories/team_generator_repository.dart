import '../../../../core/utils/result.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../entities/team_lineup_entity.dart';

abstract class TeamGeneratorRepository {
  Future<Result<TeamLineupEntity>> generateBalancedTeams({
    required List<PlayerEntity> players,
    required String matchId,
  });

  Future<Result<TeamLineupEntity>> swapPlayers({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  });

  Future<Result<TeamLineupEntity>> saveFinalLineup(TeamLineupEntity lineup);

  Future<Result<List<TeamLineupEntity>>> getLineupHistory({String? matchId});
}

import '../../../../core/utils/result.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../entities/team_lineup_entity.dart';
import '../repositories/team_generator_repository.dart';

class GenerateBalancedTeamsUseCase {
  final TeamGeneratorRepository _repository;

  const GenerateBalancedTeamsUseCase(this._repository);

  Future<Result<TeamLineupEntity>> call({
    required List<PlayerEntity> players,
    required String matchId,
  }) {
    return _repository.generateBalancedTeams(
      players: players,
      matchId: matchId,
    );
  }
}

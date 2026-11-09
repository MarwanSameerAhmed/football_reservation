import '../../../../core/utils/result.dart';
import '../entities/team_lineup_entity.dart';
import '../repositories/team_generator_repository.dart';

class SwapPlayersUseCase {
  final TeamGeneratorRepository _repository;

  const SwapPlayersUseCase(this._repository);

  Future<Result<TeamLineupEntity>> call({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  }) {
    return _repository.swapPlayers(
      lineup: lineup,
      playerAId: playerAId,
      playerBId: playerBId,
    );
  }
}

import '../../../../core/utils/result.dart';
import '../entities/player_entity.dart';
import '../repositories/player_repository.dart';

class UpdatePlayerUseCase {
  final PlayerRepository _repository;

  const UpdatePlayerUseCase(this._repository);

  Future<Result<PlayerEntity>> call(PlayerEntity player) {
    return _repository.updatePlayer(player);
  }
}

import '../../../../core/utils/result.dart';
import '../entities/player_entity.dart';
import '../repositories/player_repository.dart';

class CreatePlayerUseCase {
  final PlayerRepository _repository;

  const CreatePlayerUseCase(this._repository);

  Future<Result<PlayerEntity>> call(PlayerEntity player) {
    return _repository.createPlayer(player);
  }
}

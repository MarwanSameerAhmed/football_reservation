import '../../../../core/utils/result.dart';
import '../entities/player_entity.dart';
import '../repositories/player_repository.dart';

class GetPlayerByIdUseCase {
  final PlayerRepository _repository;

  const GetPlayerByIdUseCase(this._repository);

  Future<Result<PlayerEntity>> call(String id) {
    return _repository.getPlayerById(id);
  }
}

import '../../../../core/enums/player_position.dart';
import '../../../../core/utils/result.dart';
import '../entities/player_entity.dart';
import '../repositories/player_repository.dart';

class GetPlayersUseCase {
  final PlayerRepository _repository;

  const GetPlayersUseCase(this._repository);

  Future<Result<List<PlayerEntity>>> call({
    PlayerPosition? positionFilter,
    String? searchQuery,
  }) {
    return _repository.getPlayers(
      positionFilter: positionFilter,
      searchQuery: searchQuery,
    );
  }
}

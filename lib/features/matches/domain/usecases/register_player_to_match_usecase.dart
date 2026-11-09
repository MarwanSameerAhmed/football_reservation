import '../../../../core/enums/player_position.dart';
import '../../../../core/utils/result.dart';
import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class RegisterPlayerToMatchUseCase {
  final MatchRepository _repository;

  const RegisterPlayerToMatchUseCase(this._repository);

  Future<Result<MatchEntity>> call({
    required String matchId,
    required String playerId,
    required String playerName,
    required PlayerPosition position,
  }) {
    return _repository.registerPlayer(
      matchId: matchId,
      playerId: playerId,
      playerName: playerName,
      position: position,
    );
  }
}

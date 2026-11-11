import '../../../../core/utils/result.dart';
import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class CancelMatchRegistrationUseCase {
  final MatchRepository _repository;

  const CancelMatchRegistrationUseCase(this._repository);

  Future<Result<MatchEntity>> call({
    required String matchId,
    required String playerId,
    String? playerName,
    String? reason,
    String? customNote,
  }) {
    return _repository.cancelRegistration(
      matchId: matchId,
      playerId: playerId,
      playerName: playerName,
      reason: reason,
      customNote: customNote,
    );
  }
}

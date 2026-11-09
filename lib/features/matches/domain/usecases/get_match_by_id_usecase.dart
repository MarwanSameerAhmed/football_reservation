import '../../../../core/utils/result.dart';
import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchByIdUseCase {
  final MatchRepository _repository;

  const GetMatchByIdUseCase(this._repository);

  Future<Result<MatchEntity>> call(String matchId) {
    return _repository.getMatchById(matchId);
  }
}

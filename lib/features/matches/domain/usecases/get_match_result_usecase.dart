import '../../../../core/utils/result.dart';
import '../entities/match_result_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchResultUseCase {
  final MatchRepository _repository;

  const GetMatchResultUseCase(this._repository);

  Future<Result<MatchResultEntity?>> call(String matchId) {
    return _repository.getMatchResult(matchId);
  }
}

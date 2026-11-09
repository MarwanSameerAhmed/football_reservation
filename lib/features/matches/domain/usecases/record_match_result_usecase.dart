import '../../../../core/utils/result.dart';
import '../entities/match_result_entity.dart';
import '../repositories/match_repository.dart';

class RecordMatchResultUseCase {
  final MatchRepository _repository;

  const RecordMatchResultUseCase(this._repository);

  Future<Result<MatchResultEntity>> call(MatchResultEntity result) {
    return _repository.recordMatchResult(result);
  }
}

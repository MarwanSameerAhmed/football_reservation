import '../../../../core/utils/result.dart';
import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class CreateMatchUseCase {
  final MatchRepository _repository;

  const CreateMatchUseCase(this._repository);

  Future<Result<MatchEntity>> call(MatchEntity match) {
    return _repository.createMatch(match);
  }
}

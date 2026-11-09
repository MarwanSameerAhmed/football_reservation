import '../../../../core/enums/match_status.dart';
import '../../../../core/utils/result.dart';
import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchesUseCase {
  final MatchRepository _repository;

  const GetMatchesUseCase(this._repository);

  Future<Result<List<MatchEntity>>> call({MatchStatus? status}) {
    return _repository.getMatches(status: status);
  }
}

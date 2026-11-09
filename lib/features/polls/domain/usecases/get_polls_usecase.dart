import '../../../../core/utils/result.dart';
import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class GetPollsUseCase {
  final PollRepository _repository;

  const GetPollsUseCase(this._repository);

  Future<Result<List<PollEntity>>> call({String? matchId, bool? activeOnly}) {
    return _repository.getPolls(matchId: matchId, activeOnly: activeOnly);
  }
}

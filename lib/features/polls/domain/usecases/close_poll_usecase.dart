import '../../../../core/utils/result.dart';
import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class ClosePollUseCase {
  final PollRepository _repository;

  const ClosePollUseCase(this._repository);

  Future<Result<PollEntity>> call(String pollId) {
    return _repository.closePoll(pollId);
  }
}

import '../../../../core/utils/result.dart';
import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class VotePollUseCase {
  final PollRepository _repository;

  const VotePollUseCase(this._repository);

  Future<Result<PollEntity>> call({
    required String pollId,
    required String optionId,
    required String userId,
  }) {
    return _repository.vote(pollId: pollId, optionId: optionId, userId: userId);
  }
}

import '../../../../core/utils/result.dart';
import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class CreatePollUseCase {
  final PollRepository _repository;

  const CreatePollUseCase(this._repository);

  Future<Result<PollEntity>> call(PollEntity poll) {
    return _repository.createPoll(poll);
  }
}

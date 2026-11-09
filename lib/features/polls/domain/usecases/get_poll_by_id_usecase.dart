import '../../../../core/utils/result.dart';
import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class GetPollByIdUseCase {
  final PollRepository _repository;

  const GetPollByIdUseCase(this._repository);

  Future<Result<PollEntity>> call(String pollId) {
    return _repository.getPollById(pollId);
  }
}

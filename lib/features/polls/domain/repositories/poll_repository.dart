import '../../../../core/utils/result.dart';
import '../entities/poll_entity.dart';

abstract class PollRepository {
  Future<Result<List<PollEntity>>> getPolls({
    String? matchId,
    bool? activeOnly,
  });

  Future<Result<PollEntity>> getPollById(String pollId);

  Future<Result<PollEntity>> createPoll(PollEntity poll);

  Future<Result<PollEntity>> vote({
    required String pollId,
    required String optionId,
    required String userId,
  });

  Future<Result<PollEntity>> closePoll(String pollId);
}

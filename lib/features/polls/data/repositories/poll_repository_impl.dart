import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/poll_repository.dart';
import '../datasources/poll_remote_data_source.dart';
import '../models/poll_model.dart';

class PollRepositoryImpl implements PollRepository {
  final PollRemoteDataSource _remoteDataSource;

  const PollRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<PollEntity>>> getPolls({
    String? matchId,
    bool? activeOnly,
  }) async {
    try {
      final list = await _remoteDataSource.getPolls(
        matchId: matchId,
        activeOnly: activeOnly,
      );
      return Success(list);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PollEntity>> getPollById(String pollId) async {
    try {
      final poll = await _remoteDataSource.getPollById(pollId);
      return Success(poll);
    } on AppException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PollEntity>> createPoll(PollEntity poll) async {
    try {
      final created = await _remoteDataSource.createPoll(
        PollModel.fromEntity(poll),
      );
      return Success(created);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PollEntity>> vote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    try {
      final updated = await _remoteDataSource.vote(
        pollId: pollId,
        optionId: optionId,
        userId: userId,
      );
      return Success(updated);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PollEntity>> closePoll(String pollId) async {
    try {
      final closed = await _remoteDataSource.closePoll(pollId);
      return Success(closed);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}

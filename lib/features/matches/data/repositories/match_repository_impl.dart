import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_result_entity.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_data_source.dart';
import '../models/match_model.dart';
import '../models/match_result_model.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource _remoteDataSource;

  const MatchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<MatchEntity>>> getMatches({MatchStatus? status}) async {
    try {
      final list = await _remoteDataSource.getMatches(status: status);
      return Success(list);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MatchEntity>> getMatchById(String matchId) async {
    try {
      final match = await _remoteDataSource.getMatchById(matchId);
      return Success(match);
    } on AppException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MatchEntity>> createMatch(MatchEntity match) async {
    try {
      final created = await _remoteDataSource.createMatch(
        MatchModel.fromEntity(match),
      );
      return Success(created);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MatchEntity>> registerPlayer({
    required String matchId,
    required String playerId,
    required String playerName,
    required PlayerPosition position,
  }) async {
    try {
      final updated = await _remoteDataSource.registerPlayer(
        matchId: matchId,
        playerId: playerId,
        playerName: playerName,
        position: position,
      );
      return Success(updated);
    } on AppException catch (e) {
      if (e.code == 'DUPLICATE_REGISTRATION') {
        return FailureResult(ValidationFailure(e.message, e.code));
      }
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MatchEntity>> cancelRegistration({
    required String matchId,
    required String playerId,
    String? playerName,
    String? reason,
    String? customNote,
  }) async {
    try {
      final updated = await _remoteDataSource.cancelRegistration(
        matchId: matchId,
        playerId: playerId,
        playerName: playerName,
        reason: reason,
        customNote: customNote,
      );
      return Success(updated);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MatchResultEntity>> recordMatchResult(
    MatchResultEntity result,
  ) async {
    try {
      final saved = await _remoteDataSource.recordMatchResult(
        MatchResultModel.fromEntity(result),
      );
      return Success(saved);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MatchResultEntity?>> getMatchResult(String matchId) async {
    try {
      final result = await _remoteDataSource.getMatchResult(matchId);
      return Success(result);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<MatchEntity?> watchMatch(String matchId) =>
      _remoteDataSource.watchMatch(matchId);
}

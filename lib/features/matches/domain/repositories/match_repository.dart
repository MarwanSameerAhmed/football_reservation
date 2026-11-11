import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/utils/result.dart';
import '../entities/match_entity.dart';
import '../entities/match_result_entity.dart';

abstract class MatchRepository {
  Future<Result<List<MatchEntity>>> getMatches({MatchStatus? status});

  Future<Result<MatchEntity>> getMatchById(String matchId);

  Future<Result<MatchEntity>> createMatch(MatchEntity match);

  Future<Result<MatchEntity>> registerPlayer({
    required String matchId,
    required String playerId,
    required String playerName,
    required PlayerPosition position,
  });

  Future<Result<MatchEntity>> cancelRegistration({
    required String matchId,
    required String playerId,
    String? playerName,
    String? reason,
    String? customNote,
  });

  Future<Result<MatchResultEntity>> recordMatchResult(MatchResultEntity result);

  Future<Result<MatchResultEntity?>> getMatchResult(String matchId);

  Stream<MatchEntity?> watchMatch(String matchId);
}

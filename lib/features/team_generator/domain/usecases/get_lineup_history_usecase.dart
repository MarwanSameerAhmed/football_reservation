import '../../../../core/utils/result.dart';
import '../entities/team_lineup_entity.dart';
import '../repositories/team_generator_repository.dart';

class GetLineupHistoryUseCase {
  final TeamGeneratorRepository _repository;

  const GetLineupHistoryUseCase(this._repository);

  Future<Result<List<TeamLineupEntity>>> call({String? matchId}) {
    return _repository.getLineupHistory(matchId: matchId);
  }
}

import '../../../../core/utils/result.dart';
import '../entities/team_lineup_entity.dart';
import '../repositories/team_generator_repository.dart';

class SaveFinalLineupUseCase {
  final TeamGeneratorRepository _repository;

  const SaveFinalLineupUseCase(this._repository);

  Future<Result<TeamLineupEntity>> call(TeamLineupEntity lineup) {
    return _repository.saveFinalLineup(lineup);
  }
}

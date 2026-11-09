import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/player_entity.dart';
import '../entities/player_skills.dart';
import '../repositories/player_repository.dart';

/// Enforces the strict security rule that only Administrators can update player assessments.
class UpdatePlayerSkillsUseCase {
  final PlayerRepository _repository;

  const UpdatePlayerSkillsUseCase(this._repository);

  Future<Result<PlayerEntity>> call({
    required String playerId,
    required PlayerSkills skills,
    required UserRole updaterRole,
  }) async {
    // Domain rule verification
    if (!updaterRole.isAdmin) {
      return const FailureResult(
        PermissionDeniedFailure(
          'فقط مسؤول المجموعة (Admin) يملك صلاحية تعديل التقييمات الفنية للاعبين',
        ),
      );
    }

    return _repository.updatePlayerSkills(
      playerId: playerId,
      skills: skills,
      updaterRole: updaterRole,
    );
  }
}

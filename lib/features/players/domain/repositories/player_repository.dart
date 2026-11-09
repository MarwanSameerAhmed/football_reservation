import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/result.dart';
import '../entities/player_entity.dart';
import '../entities/player_skills.dart';

/// Contract definition for Player repository.
abstract class PlayerRepository {
  Future<Result<List<PlayerEntity>>> getPlayers({
    PlayerPosition? positionFilter,
    String? searchQuery,
  });

  Future<Result<PlayerEntity>> getPlayerById(String id);

  Future<Result<PlayerEntity>> createPlayer(PlayerEntity player);

  Future<Result<PlayerEntity>> updatePlayer(PlayerEntity player);

  /// Updates player technical ratings.
  /// Strict Business Rule: Only [UserRole.admin] can execute this operation.
  Future<Result<PlayerEntity>> updatePlayerSkills({
    required String playerId,
    required PlayerSkills skills,
    required UserRole updaterRole,
  });

  Stream<List<PlayerEntity>> get playersStream;
}

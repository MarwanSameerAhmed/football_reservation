import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_skills.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_remote_data_source.dart';
import '../models/player_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerRemoteDataSource _remoteDataSource;

  const PlayerRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<PlayerEntity>>> getPlayers({
    PlayerPosition? positionFilter,
    String? searchQuery,
  }) async {
    try {
      final list = await _remoteDataSource.getPlayers(
        positionFilter: positionFilter,
        searchQuery: searchQuery,
      );
      return Success(list);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PlayerEntity>> getPlayerById(String id) async {
    try {
      final player = await _remoteDataSource.getPlayerById(id);
      return Success(player);
    } on AppException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PlayerEntity>> createPlayer(PlayerEntity player) async {
    try {
      final created = await _remoteDataSource.createPlayer(
        PlayerModel.fromEntity(player),
      );
      return Success(created);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PlayerEntity>> updatePlayer(PlayerEntity player) async {
    try {
      final updated = await _remoteDataSource.updatePlayer(
        PlayerModel.fromEntity(player),
      );
      return Success(updated);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PlayerEntity>> updatePlayerSkills({
    required String playerId,
    required PlayerSkills skills,
    required UserRole updaterRole,
  }) async {
    // Secondary safety check in data layer
    if (!updaterRole.isAdmin) {
      return const FailureResult(
        PermissionDeniedFailure(
          'فقط مسؤول المجموعة يمكنه تعديل التقييم الفني للاعبين',
        ),
      );
    }

    try {
      final updated = await _remoteDataSource.updatePlayerSkills(
        playerId,
        skills,
      );
      return Success(updated);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<PlayerEntity>> get playersStream =>
      _remoteDataSource.playersStream;
}

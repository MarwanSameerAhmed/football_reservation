import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Contract definition for Authentication repository.
abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    UserRole role = UserRole.player,
  });

  Future<Result<void>> signOut();

  Future<Result<UserEntity?>> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}

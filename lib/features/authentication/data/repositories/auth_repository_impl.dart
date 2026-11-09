import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Concrete implementation of [AuthRepository].
///
/// Encapsulates data sources and translates low-level data exceptions
/// into high-level Domain failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmail(
        email,
        password,
      );
      return Success(userModel);
    } on AuthException catch (e) {
      return FailureResult(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    UserRole role = UserRole.player,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
      );
      return Success(userModel);
    } on AuthException catch (e) {
      return FailureResult(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Success(null);
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Success(userModel);
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remoteDataSource.authStateChanges;
}

import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  const SignUpUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    UserRole role = UserRole.player,
  }) {
    return _repository.signUpWithEmail(
      email: email.trim(),
      password: password,
      displayName: displayName.trim(),
      phoneNumber: phoneNumber?.trim(),
      role: role,
    );
  }
}

import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current session status on application startup.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Trigger sign-in with email and password.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Trigger sign-up for a new user account.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String? phoneNumber;
  final UserRole role;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.phoneNumber,
    this.role = UserRole.player,
  });

  @override
  List<Object?> get props => [email, password, displayName, phoneNumber, role];
}

/// Trigger sign-out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

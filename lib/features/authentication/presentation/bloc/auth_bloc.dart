import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Business Logic Component managing user authentication and sessions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final PushNotificationService? _pushNotificationService;
  bool _hasAdminPrivilege = false;

  AuthBloc({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    PushNotificationService? pushNotificationService,
  }) : _getCurrentUserUseCase = getCurrentUserUseCase,
       _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _signOutUseCase = signOutUseCase,
       _pushNotificationService = pushNotificationService,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<ToggleUserRoleRequested>(_onToggleUserRoleRequested);
    on<AuthActivatePlayerRequested>(_onAuthActivatePlayerRequested);
  }

  void _onToggleUserRoleRequested(
    ToggleUserRoleRequested event,
    Emitter<AuthState> emit,
  ) {
    if (state is Authenticated && _hasAdminPrivilege) {
      final currentUser = (state as Authenticated).user;
      final newRole = currentUser.role.isAdmin
          ? UserRole.player
          : UserRole.admin;
      final updatedUser = currentUser.copyWith(role: newRole);
      emit(Authenticated(updatedUser, canSwitchRolePreview: true));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      onSuccess: (user) {
        if (user != null) {
          _hasAdminPrivilege = user.role.isAdmin;
          _pushNotificationService?.saveTokenToUser(user.id);
          emit(Authenticated(user, canSwitchRolePreview: _hasAdminPrivilege));
        } else {
          _hasAdminPrivilege = false;
          emit(const Unauthenticated());
        }
      },
      onFailure: (failure) => emit(AuthFailureState(failure.message)),
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      onSuccess: (user) {
        _hasAdminPrivilege = user.role.isAdmin;
        _pushNotificationService?.saveTokenToUser(user.id);
        emit(Authenticated(user, canSwitchRolePreview: _hasAdminPrivilege));
      },
      onFailure: (failure) => emit(AuthFailureState(failure.message)),
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUpUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      phoneNumber: event.phoneNumber,
      role: event.role,
    );
    result.fold(
      onSuccess: (user) {
        _hasAdminPrivilege = user.role.isAdmin;
        _pushNotificationService?.saveTokenToUser(user.id);
        emit(Authenticated(user, canSwitchRolePreview: _hasAdminPrivilege));
      },
      onFailure: (failure) => emit(AuthFailureState(failure.message)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUserId = state is Authenticated
        ? (state as Authenticated).user.id
        : null;
    emit(const AuthLoading());
    final result = await _signOutUseCase();
    result.fold(
      onSuccess: (_) {
        _hasAdminPrivilege = false;
        if (currentUserId != null) {
          _pushNotificationService?.removeTokenFromUser(currentUserId);
        }
        emit(const Unauthenticated());
      },
      onFailure: (failure) => emit(AuthFailureState(failure.message)),
    );
  }

  Future<void> _onAuthActivatePlayerRequested(
    AuthActivatePlayerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final cleanPhone = event.phoneNumber.replaceAll(RegExp(r'[\s\-\+]'), '');
    final email = cleanPhone.isNotEmpty
        ? '$cleanPhone@kickoff.app'
        : '${event.id}@kickoff.app';
    final effectivePassword =
        (event.password != null && event.password!.trim().length >= 6)
        ? event.password!.trim()
        : 'passwordless_player_token';

    final result = await _signUpUseCase(
      email: email,
      password: effectivePassword,
      displayName: event.displayName,
      phoneNumber: event.phoneNumber.isNotEmpty ? event.phoneNumber : null,
      role: UserRole.player,
    );
    result.fold(
      onSuccess: (user) {
        _hasAdminPrivilege = false;
        final userWithPhoto = user.copyWith(photoUrl: event.photoUrl);
        _pushNotificationService?.saveTokenToUser(userWithPhoto.id);
        emit(Authenticated(userWithPhoto));
      },
      onFailure: (failure) => emit(AuthFailureState(failure.message)),
    );
  }
}

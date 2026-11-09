import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/user_role.dart';
import 'package:football_reservation/core/utils/result.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:football_reservation/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:football_reservation/features/authentication/domain/entities/user_entity.dart';
import 'package:football_reservation/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:football_reservation/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:football_reservation/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:football_reservation/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:football_reservation/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:football_reservation/features/authentication/presentation/bloc/auth_event.dart';
import 'package:football_reservation/features/authentication/presentation/bloc/auth_state.dart';

void main() {
  group('Authentication Domain & Data Tests', () {
    late MockAuthRemoteDataSource dataSource;
    late AuthRepositoryImpl repository;
    late SignInUseCase signInUseCase;
    late SignUpUseCase signUpUseCase;
    late SignOutUseCase signOutUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;

    setUp(() {
      dataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(dataSource);
      signInUseCase = SignInUseCase(repository);
      signUpUseCase = SignUpUseCase(repository);
      signOutUseCase = SignOutUseCase(repository);
      getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    });

    test('SignInUseCase signs in existing admin user successfully', () async {
      final result = await signInUseCase(
        email: 'marwan@kickoff.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity>>());
      final user = (result as Success<UserEntity>).data;
      expect(user.displayName, 'مروان سمير');
      expect(user.role, UserRole.admin);
      expect(user.isAdmin, isTrue);
    });

    test(
      'SignUpUseCase creates a new player account with UserRole.player',
      () async {
        final result = await signUpUseCase(
          email: 'newplayer@kickoff.com',
          password: 'securePassword',
          displayName: 'كابتن ماجد',
          role: UserRole.player,
        );

        expect(result, isA<Success<UserEntity>>());
        final user = (result as Success<UserEntity>).data;
        expect(user.displayName, 'كابتن ماجد');
        expect(user.role, UserRole.player);
        expect(user.isPlayer, isTrue);
      },
    );

    test('SignOutUseCase clears user session', () async {
      final signOutResult = await signOutUseCase();
      expect(signOutResult, isA<Success<void>>());

      final currentUserResult = await getCurrentUserUseCase();
      expect(currentUserResult, isA<Success<UserEntity?>>());
      expect((currentUserResult as Success<UserEntity?>).data, isNull);
    });
  });

  group('AuthBloc State Transitions', () {
    late MockAuthRemoteDataSource dataSource;
    late AuthRepositoryImpl repository;
    late SignInUseCase signInUseCase;
    late SignUpUseCase signUpUseCase;
    late SignOutUseCase signOutUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;
    late AuthBloc authBloc;

    setUp(() {
      dataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(dataSource);
      signInUseCase = SignInUseCase(repository);
      signUpUseCase = SignUpUseCase(repository);
      signOutUseCase = SignOutUseCase(repository);
      getCurrentUserUseCase = GetCurrentUserUseCase(repository);

      authBloc = AuthBloc(
        getCurrentUserUseCase: getCurrentUserUseCase,
        signInUseCase: signInUseCase,
        signUpUseCase: signUpUseCase,
        signOutUseCase: signOutUseCase,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    test('Emits [AuthLoading, Authenticated] when sign-in succeeds', () async {
      final expectedStates = [
        const AuthLoading(),
        isA<Authenticated>().having(
          (s) => s.user.email,
          'email',
          'marwan@kickoff.com',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthSignInRequested(
          email: 'marwan@kickoff.com',
          password: 'password123',
        ),
      );
    });

    test('Emits [AuthLoading, Unauthenticated] on sign-out', () async {
      final expectedStates = [const AuthLoading(), const Unauthenticated()];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthSignOutRequested());
    });
  });
}

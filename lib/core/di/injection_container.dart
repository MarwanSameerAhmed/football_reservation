import 'package:get_it/get_it.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/get_auth_state_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/sign_out_usecase.dart';
import '../../features/authentication/domain/usecases/sign_up_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/matches/data/datasources/match_remote_data_source.dart';
import '../../features/matches/data/repositories/match_repository_impl.dart';
import '../../features/matches/domain/repositories/match_repository.dart';
import '../../features/matches/domain/usecases/cancel_match_registration_usecase.dart';
import '../../features/matches/domain/usecases/create_match_usecase.dart';
import '../../features/matches/domain/usecases/get_match_by_id_usecase.dart';
import '../../features/matches/domain/usecases/get_matches_usecase.dart';
import '../../features/matches/domain/usecases/get_match_result_usecase.dart';
import '../../features/matches/domain/usecases/record_match_result_usecase.dart';
import '../../features/matches/domain/usecases/register_player_to_match_usecase.dart';
import '../../features/matches/presentation/bloc/matches_bloc.dart';
import '../../features/players/data/datasources/player_remote_data_source.dart';
import '../../features/players/data/repositories/player_repository_impl.dart';
import '../../features/players/domain/repositories/player_repository.dart';
import '../../features/players/domain/usecases/create_player_usecase.dart';
import '../../features/players/domain/usecases/get_player_by_id_usecase.dart';
import '../../features/players/domain/usecases/get_players_usecase.dart';
import '../../features/players/domain/usecases/update_player_skills_usecase.dart';
import '../../features/players/domain/usecases/update_player_usecase.dart';
import '../../features/players/presentation/bloc/players_bloc.dart';
import '../../features/team_generator/data/datasources/team_generator_remote_data_source.dart';
import '../../features/team_generator/data/repositories/team_generator_repository_impl.dart';
import '../../features/team_generator/domain/repositories/team_generator_repository.dart';
import '../../features/team_generator/domain/usecases/generate_balanced_teams_usecase.dart';
import '../../features/team_generator/domain/usecases/get_lineup_history_usecase.dart';
import '../../features/team_generator/domain/usecases/save_final_lineup_usecase.dart';
import '../../features/team_generator/domain/usecases/swap_players_usecase.dart';
import '../../features/team_generator/presentation/bloc/team_generator_bloc.dart';
import '../../features/polls/data/datasources/poll_remote_data_source.dart';
import '../../features/polls/data/repositories/poll_repository_impl.dart';
import '../../features/polls/domain/repositories/poll_repository.dart';
import '../../features/polls/domain/usecases/close_poll_usecase.dart';
import '../../features/polls/domain/usecases/create_poll_usecase.dart';
import '../../features/polls/domain/usecases/get_poll_by_id_usecase.dart';
import '../../features/polls/domain/usecases/get_polls_usecase.dart';
import '../../features/polls/domain/usecases/vote_poll_usecase.dart';
import '../../features/polls/presentation/bloc/polls_bloc.dart';
import '../../features/statistics/data/datasources/statistics_remote_data_source.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
import '../../features/statistics/domain/usecases/get_group_leaderboards_usecase.dart';
import '../../features/statistics/domain/usecases/get_player_stats_usecase.dart';
import '../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../services/firebase_notification_sender_service.dart';
import '../services/push_notification_service.dart';

/// Global Dependency Injection service locator.
final sl = GetIt.instance;

/// Initialize global singletons and dependencies.
///
/// Set [useFirebase] to true to connect live to Firebase services
/// (Auth, Cloud Firestore), or false to use in-memory mock data sources.
Future<void> setupLocator({bool useFirebase = false}) async {
  if (sl.isRegistered<AuthRemoteDataSource>()) {
    await sl.reset();
  }

  // ── Authentication Feature ────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => useFirebase
        ? FirebaseAuthRemoteDataSource()
        : MockAuthRemoteDataSource(),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthStateUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      getCurrentUserUseCase: sl(),
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      pushNotificationService: sl(),
    ),
  );

  // ── Players Feature ───────────────────────────────────────────────────────
  sl.registerLazySingleton<PlayerRemoteDataSource>(
    () => useFirebase
        ? FirebasePlayerRemoteDataSource()
        : MockPlayerRemoteDataSource(),
  );
  sl.registerLazySingleton<PlayerRepository>(() => PlayerRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetPlayersUseCase(sl()));
  sl.registerLazySingleton(() => GetPlayerByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlayerUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlayerUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlayerSkillsUseCase(sl()));

  sl.registerFactory(
    () => PlayersBloc(getPlayersUseCase: sl(), updatePlayerSkillsUseCase: sl()),
  );

  // ── Matches & Registrations Feature ───────────────────────────────────────
  sl.registerLazySingleton<MatchRemoteDataSource>(
    () => useFirebase
        ? FirebaseMatchRemoteDataSource()
        : MockMatchRemoteDataSource(),
  );
  sl.registerLazySingleton<MatchRepository>(() => MatchRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetMatchesUseCase(sl()));
  sl.registerLazySingleton(() => GetMatchByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateMatchUseCase(sl()));
  sl.registerLazySingleton(() => RegisterPlayerToMatchUseCase(sl()));
  sl.registerLazySingleton(() => CancelMatchRegistrationUseCase(sl()));
  sl.registerLazySingleton(() => RecordMatchResultUseCase(sl()));
  sl.registerLazySingleton(() => GetMatchResultUseCase(sl()));

  sl.registerFactory(
    () => MatchesBloc(
      getMatchesUseCase: sl(),
      getMatchByIdUseCase: sl(),
      registerPlayerToMatchUseCase: sl(),
      cancelMatchRegistrationUseCase: sl(),
      recordMatchResultUseCase: sl(),
      notificationSenderService: sl(),
    ),
  );

  // ── Team Generator Feature ────────────────────────────────────────────────
  sl.registerLazySingleton<TeamGeneratorRemoteDataSource>(
    () => useFirebase
        ? FirebaseTeamGeneratorRemoteDataSource()
        : MockTeamGeneratorRemoteDataSource(),
  );
  sl.registerLazySingleton<TeamGeneratorRepository>(
    () => TeamGeneratorRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GenerateBalancedTeamsUseCase(sl()));
  sl.registerLazySingleton(() => SwapPlayersUseCase(sl()));
  sl.registerLazySingleton(() => SaveFinalLineupUseCase(sl()));
  sl.registerLazySingleton(() => GetLineupHistoryUseCase(sl()));

  sl.registerFactory(
    () => TeamGeneratorBloc(
      generateBalancedTeamsUseCase: sl(),
      swapPlayersUseCase: sl(),
      saveFinalLineupUseCase: sl(),
      getLineupHistoryUseCase: sl(),
      notificationSenderService: sl(),
    ),
  );

  // ── Polls Feature ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<PollRemoteDataSource>(
    () => useFirebase
        ? FirebasePollRemoteDataSource()
        : MockPollRemoteDataSource(),
  );
  sl.registerLazySingleton<PollRepository>(() => PollRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetPollsUseCase(sl()));
  sl.registerLazySingleton(() => GetPollByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreatePollUseCase(sl()));
  sl.registerLazySingleton(() => VotePollUseCase(sl()));
  sl.registerLazySingleton(() => ClosePollUseCase(sl()));

  sl.registerFactory(
    () => PollsBloc(
      getPollsUseCase: sl(),
      getPollByIdUseCase: sl(),
      createPollUseCase: sl(),
      votePollUseCase: sl(),
      closePollUseCase: sl(),
    ),
  );

  // ── Statistics Feature ────────────────────────────────────────────────────
  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => useFirebase
        ? FirebaseStatisticsRemoteDataSource()
        : MockStatisticsRemoteDataSource(),
  );
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetGroupLeaderboardsUseCase(sl()));
  sl.registerLazySingleton(() => GetPlayerStatsUseCase(sl()));

  sl.registerFactory(() => StatisticsBloc(getGroupLeaderboardsUseCase: sl()));

  // ── Notifications Feature ─────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => useFirebase
        ? FirebaseNotificationRemoteDataSource()
        : MockNotificationRemoteDataSource(),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));

  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),
    ),
  );

  // ── Push Notification Service (FCM) ──────────────────────────────────────
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(),
  );

  sl.registerLazySingleton<FirebaseNotificationSenderService>(
    () => FirebaseNotificationSenderService(),
  );
}

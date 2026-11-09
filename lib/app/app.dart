import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/di/injection_container.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/authentication/presentation/bloc/auth_event.dart';
import '../features/matches/presentation/bloc/matches_bloc.dart';
import '../features/matches/presentation/bloc/matches_event.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../features/notifications/presentation/bloc/notifications_event.dart';
import '../features/players/presentation/bloc/players_bloc.dart';
import '../features/players/presentation/bloc/players_event.dart';
import '../features/polls/presentation/bloc/polls_bloc.dart';
import '../features/polls/presentation/bloc/polls_event.dart';
import '../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../features/statistics/presentation/bloc/statistics_event.dart';
import '../features/team_generator/presentation/bloc/team_generator_bloc.dart';
import 'localization/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

/// Root application widget for Kickoff.
class KickoffApp extends StatelessWidget {
  const KickoffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => sl<PlayersBloc>()..add(const LoadPlayersRequested()),
        ),
        BlocProvider(
          create: (_) => sl<MatchesBloc>()..add(const LoadMatchesRequested()),
        ),
        BlocProvider(create: (_) => sl<TeamGeneratorBloc>()),
        BlocProvider(
          create: (_) => sl<PollsBloc>()..add(const LoadPollsRequested()),
        ),
        BlocProvider(
          create: (_) =>
              sl<StatisticsBloc>()..add(const LoadStatisticsRequested()),
        ),
        BlocProvider(
          create: (_) =>
              sl<NotificationsBloc>()..add(const LoadNotificationsRequested()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Kickoff',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: state.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

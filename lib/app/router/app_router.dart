import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/match_status.dart';
import '../../core/enums/player_position.dart';
import '../../core/presentation/widgets/kickoff_bottom_nav_bar.dart';
import '../../features/authentication/presentation/pages/player_activation_page.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/sign_up_page.dart';
import '../../features/matches/domain/entities/match_entity.dart';
import '../../features/matches/presentation/pages/home_page.dart';
import '../../features/matches/presentation/pages/match_details_page.dart';
import '../../features/matches/presentation/pages/matches_page.dart';
import '../../features/matches/presentation/pages/record_match_result_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/players/domain/entities/player_entity.dart';
import '../../features/players/domain/entities/player_skills.dart';
import '../../features/players/presentation/pages/player_details_page.dart';
import '../../features/players/presentation/pages/players_list_page.dart';
import '../../features/polls/presentation/pages/polls_page.dart';
import '../../features/registrations/presentation/pages/reserve_spot_page.dart';
import '../../features/splash/presentation/pages/video_splash_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/team_generator/presentation/pages/team_generator_page.dart';

/// Central GoRouter configuration for Kickoff.
/// Uses StatefulShellRoute to provide a persistent, non-disappearing capsule bottom navigation bar
/// across all 5 primary branches (Home, Matches, Players, Polls, Statistics).
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VideoSplashPage(),
      ),

      // 2. Auth Flows
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignUpPage(),
      ),

      // 3. Persistent Shell with Bottom Navigation Bar (3 core tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: KickoffBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              items: const [
                NavItemData(icon: Icons.home_rounded, label: 'الرئيسية'),
                NavItemData(
                  icon: Icons.sports_soccer_rounded,
                  label: 'المباريات',
                ),
                NavItemData(icon: Icons.groups_rounded, label: 'المجموعة'),
              ],
            ),
          );
        },
        branches: [
          // Branch 0: Home Tab
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const HomePage()),
            ],
          ),

          // Branch 1: Matches Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matches',
                builder: (context, state) => const MatchesPage(),
              ),
            ],
          ),

          // Branch 2: Squad & Leaderboard Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/players',
                builder: (context, state) => const PlayersListPage(),
              ),
            ],
          ),
        ],
      ),

      // 4. Modal / Full Screen Detail Flows (Outside Shell)
      GoRoute(
        path: '/polls',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final matchId = state.extra as String?;
          return PollsPage(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/statistics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StatisticsPage(),
      ),

      // 4. Modal / Full Screen Detail Flows (Outside Shell)
      GoRoute(
        path: '/match-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MatchDetailsPage(),
      ),
      GoRoute(
        path: '/record-result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final match = state.extra as MatchEntity;
          return RecordMatchResultPage(match: match);
        },
      ),
      GoRoute(
        path: '/reserve',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final match = state.extra as MatchEntity?;
          return ReserveSpotPage(match: match);
        },
      ),
      GoRoute(
        path: '/player-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final player =
              state.extra as PlayerEntity? ??
              PlayerEntity(
                id: state.pathParameters['id'] ?? 'p1',
                userId: 'u1',
                name: 'مروان سمير',
                primaryPosition: PlayerPosition.midfielder,
                skills: const PlayerSkills(
                  pace: 82,
                  shooting: 80,
                  passing: 88,
                  defending: 76,
                  physical: 78,
                  goalkeeping: 50,
                ),
                createdAt: DateTime(2026, 1, 1),
              );
          return PlayerDetailsPage(initialPlayer: player);
        },
      ),
      GoRoute(
        path: '/team-generator',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final match =
              state.extra as MatchEntity? ??
              MatchEntity(
                id: 'm1',
                title: 'مباراة الجمعة الكبرى',
                pitchName: 'ملعب النخبة الدولي',
                location: 'حي النخيل • الرياض',
                matchDateTime: DateTime(2026, 11, 7, 20, 0),
                maxPlayers: 18,
                feePerPlayer: 0.0,
                status: MatchStatus.upcoming,
                createdAt: DateTime(2026, 1, 1),
              );
          return TeamGeneratorPage(match: match);
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/join',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return PlayerActivationPage(
            playerId:
                queryParams['id'] ??
                'p_${DateTime.now().millisecondsSinceEpoch}',
            name: queryParams['name'] ?? '',
            phone: queryParams['phone'] ?? '',
            role: queryParams['role'] ?? 'player',
          );
        },
      ),
      GoRoute(
        path: '/activate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return PlayerActivationPage(
            playerId:
                queryParams['id'] ??
                'p_${DateTime.now().millisecondsSinceEpoch}',
            name: queryParams['name'] ?? '',
            phone: queryParams['phone'] ?? '',
            role: queryParams['role'] ?? 'player',
          );
        },
      ),
    ],
  );
}

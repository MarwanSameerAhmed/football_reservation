import 'package:go_router/go_router.dart';
import '../../core/enums/match_status.dart';
import '../../core/enums/player_position.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/sign_up_page.dart';
import '../../features/matches/domain/entities/match_entity.dart';
import '../../features/matches/presentation/pages/home_page.dart';
import '../../features/matches/presentation/pages/match_details_page.dart';
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
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const VideoSplashPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/match-details',
        builder: (context, state) => const MatchDetailsPage(),
      ),
      GoRoute(
        path: '/reserve',
        builder: (context, state) {
          final match = state.extra as MatchEntity?;
          return ReserveSpotPage(match: match);
        },
      ),
      GoRoute(
        path: '/players',
        builder: (context, state) => const PlayersListPage(),
      ),
      GoRoute(
        path: '/player-details/:id',
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
        builder: (context, state) {
          final match =
              state.extra as MatchEntity? ??
              MatchEntity(
                id: 'm1',
                title: 'مباراة الجمعة الكبرى',
                pitchName: 'ملعب النخبة الدولي',
                location: 'حي النخيل • الرياض',
                matchDateTime: DateTime(2026, 11, 7, 20, 0),
                maxPlayers: 14,
                feePerPlayer: 0.0,
                status: MatchStatus.upcoming,
                createdAt: DateTime(2026, 1, 1),
              );
          return TeamGeneratorPage(match: match);
        },
      ),
      GoRoute(
        path: '/polls',
        builder: (context, state) {
          final matchId = state.extra as String?;
          return PollsPage(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}

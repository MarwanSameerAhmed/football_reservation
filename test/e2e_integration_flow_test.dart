import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/di/injection_container.dart';
import 'package:football_reservation/core/enums/player_position.dart';
import 'package:football_reservation/core/enums/user_role.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:football_reservation/features/authentication/domain/repositories/auth_repository.dart';
import 'package:football_reservation/features/matches/domain/entities/goal_event_entity.dart';
import 'package:football_reservation/features/matches/domain/entities/match_result_entity.dart';
import 'package:football_reservation/features/matches/domain/repositories/match_repository.dart';
import 'package:football_reservation/features/notifications/domain/repositories/notification_repository.dart';
import 'package:football_reservation/features/players/domain/repositories/player_repository.dart';
import 'package:football_reservation/features/polls/domain/repositories/poll_repository.dart';
import 'package:football_reservation/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:football_reservation/features/team_generator/domain/repositories/team_generator_repository.dart';

void main() {
  setUpAll(() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      await setupLocator();
    }
  });

  group('Kickoff Complete End-to-End User Journey Tests', () {
    test('E2E Flow 1: Authentication & RBAC role permissions', () async {
      final authRepo = sl<AuthRepository>();

      // 1. Admin signs in
      final adminRes = await authRepo.signInWithEmail(
        email: 'marwan@kickoff.com',
        password: 'Password123',
      );
      expect(adminRes.isSuccess, isTrue);
      final adminUser = adminRes.dataOrNull!;
      expect(adminUser.role, equals(UserRole.admin));
      expect(adminUser.role.isAdmin, isTrue);

      // 2. Sign out
      final signOutRes = await authRepo.signOut();
      expect(signOutRes.isSuccess, isTrue);

      // 3. New Player registers
      final playerRes = await authRepo.signUpWithEmail(
        email: 'tariq@kickoff.app',
        password: 'Password123',
        displayName: 'طارق زياد',
        role: UserRole.player,
      );
      expect(playerRes.isSuccess, isTrue);
      final playerUser = playerRes.dataOrNull!;
      expect(playerUser.role, equals(UserRole.player));
      expect(playerUser.role.isPlayer, isTrue);
    });

    test(
      'E2E Flow 2: Matches, Attendance RSVP & Waiting list promotion',
      () async {
        final matchRepo = sl<MatchRepository>();

        // 1. Retrieve upcoming matches
        final matchesRes = await matchRepo.getMatches();
        expect(matchesRes.isSuccess, isTrue);
        final matches = matchesRes.dataOrNull!;
        expect(matches, isNotEmpty);
        final match = matches.first;

        // 2. Register a confirmed player
        final regRes = await matchRepo.registerPlayer(
          matchId: match.id,
          playerId: 'player_test_1',
          playerName: 'لاعب تجريبي',
          position: PlayerPosition.forward,
        );
        expect(regRes.isSuccess, isTrue);

        // 3. Prevent duplicate registration
        final duplicateRes = await matchRepo.registerPlayer(
          matchId: match.id,
          playerId: 'player_test_1',
          playerName: 'لاعب تجريبي',
          position: PlayerPosition.forward,
        );
        expect(duplicateRes.isFailure, isTrue);

        // 4. Cancel registration
        final cancelRes = await matchRepo.cancelRegistration(
          matchId: match.id,
          playerId: 'player_test_1',
        );
        expect(cancelRes.isSuccess, isTrue);
      },
    );

    test(
      'E2E Flow 3: Intelligent Team Generation, Swapping & Lineup Saving',
      () async {
        final playerRepo = sl<PlayerRepository>();
        final teamRepo = sl<TeamGeneratorRepository>();

        // 1. Fetch available squad players
        final playersRes = await playerRepo.getPlayers();
        expect(playersRes.isSuccess, isTrue);
        final allPlayers = playersRes.dataOrNull!;
        expect(allPlayers.length, greaterThanOrEqualTo(6));

        // 2. Generate balanced teams
        final lineupRes = await teamRepo.generateBalancedTeams(
          matchId: 'm1',
          players: allPlayers,
        );
        expect(lineupRes.isSuccess, isTrue);
        final lineup = lineupRes.dataOrNull!;
        expect(lineup.teamA.players, isNotEmpty);
        expect(lineup.teamB.players, isNotEmpty);
        expect(lineup.balancePercentage, greaterThanOrEqualTo(80));

        // 3. Tactical Swap
        final playerFromA = lineup.teamA.players.first;
        final playerFromB = lineup.teamB.players.first;
        final swapRes = await teamRepo.swapPlayers(
          lineup: lineup,
          playerAId: playerFromA.id,
          playerBId: playerFromB.id,
        );
        expect(swapRes.isSuccess, isTrue);
        final swappedLineup = swapRes.dataOrNull!;
        expect(
          swappedLineup.teamA.players.any((p) => p.id == playerFromB.id),
          isTrue,
        );

        // 4. Finalize Lineup
        final saveRes = await teamRepo.saveFinalLineup(swappedLineup);
        expect(saveRes.isSuccess, isTrue);
      },
    );

    test(
      'E2E Flow 4: Interactive Poll Voting, Duplicate Vote Switch & Closure',
      () async {
        final pollRepo = sl<PollRepository>();

        // 1. Fetch active polls
        final pollsRes = await pollRepo.getPolls();
        expect(pollsRes.isSuccess, isTrue);
        final polls = pollsRes.dataOrNull!;
        expect(polls, isNotEmpty);
        final activePoll = polls.firstWhere((p) => p.isActive);

        // 2. Cast vote for first option
        final opt1 = activePoll.options[0];
        final voteRes1 = await pollRepo.vote(
          pollId: activePoll.id,
          optionId: opt1.id,
          userId: 'voter_99',
        );
        expect(voteRes1.isSuccess, isTrue);

        // 3. Switch vote to second option
        final opt2 = activePoll.options[1];
        final voteRes2 = await pollRepo.vote(
          pollId: activePoll.id,
          optionId: opt2.id,
          userId: 'voter_99',
        );
        expect(voteRes2.isSuccess, isTrue);

        // 4. Close poll
        final closeRes = await pollRepo.closePoll(activePoll.id);
        expect(closeRes.isSuccess, isTrue);
      },
    );

    test(
      'E2E Flow 5: Recording Match Result, Scoreboard & Stats Update',
      () async {
        final matchRepo = sl<MatchRepository>();
        final statsRepo = sl<StatisticsRepository>();

        // 1. Record official match result
        final resultEntity = MatchResultEntity(
          id: 'res_1',
          matchId: 'm1',
          teamAScore: 4,
          teamBScore: 3,
          goals: const [
            GoalEventEntity(
              id: 'g1',
              scorerPlayerId: 'p2',
              scorerName: 'سفيان المهاجم',
              teamName: 'الفريق الأول (الأخضر)',
              minute: 14,
            ),
            GoalEventEntity(
              id: 'g2',
              scorerPlayerId: 'p1',
              scorerName: 'مروان سمير',
              teamName: 'الفريق الأول (الأخضر)',
              assistPlayerName: 'سفيان المهاجم',
              minute: 42,
            ),
          ],
          manOfTheMatchPlayerId: 'p2',
          manOfTheMatchName: 'سفيان المهاجم',
          isLocked: true,
          recordedAt: DateTime.now(),
        );

        final recordRes = await matchRepo.recordMatchResult(resultEntity);
        expect(recordRes.isSuccess, isTrue);

        // 2. Check updated leaderboards
        final boardsRes = await statsRepo.getGroupLeaderboards();
        expect(boardsRes.isSuccess, isTrue);
        final boards = boardsRes.dataOrNull!;
        expect(boards.topScorers, isNotEmpty);
        expect(boards.topAssisters, isNotEmpty);
        expect(boards.topCleanSheets, isNotEmpty);

        // 3. Check individual player stats
        final playerStatsRes = await statsRepo.getPlayerStats('p1');
        expect(playerStatsRes.isSuccess, isTrue);
        final p1Stats = playerStatsRes.dataOrNull!;
        expect(p1Stats.winRate, greaterThan(0));
      },
    );

    test(
      'E2E Flow 6: In-App Notifications & Unread Badge Management',
      () async {
        final notifRepo = sl<NotificationRepository>();

        // 1. Retrieve notifications
        final notifsRes = await notifRepo.getNotifications();
        expect(notifsRes.isSuccess, isTrue);
        final notifs = notifsRes.dataOrNull!;
        expect(notifs.length, greaterThanOrEqualTo(4));

        // 2. Mark single notification as read
        final unread = notifs.firstWhere((n) => !n.isRead);
        final markRes = await notifRepo.markAsRead(unread.id);
        expect(markRes.isSuccess, isTrue);

        // 3. Mark all notifications as read
        final markAllRes = await notifRepo.markAllAsRead();
        expect(markAllRes.isSuccess, isTrue);

        final updatedNotifs = (await notifRepo.getNotifications()).dataOrNull!;
        expect(updatedNotifs.every((n) => n.isRead), isTrue);
      },
    );
  });
}

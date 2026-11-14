import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/motion/kickoff_motion.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../../players/presentation/widgets/add_player_dialog.dart';
import '../../../polls/presentation/bloc/polls_bloc.dart';
import '../../../polls/presentation/bloc/polls_event.dart';
import '../../../polls/presentation/bloc/polls_state.dart';
import '../../../polls/presentation/widgets/create_poll_sheet.dart';
import '../../../polls/presentation/widgets/poll_card.dart';
import '../../../../core/enums/match_status.dart';
import '../../domain/entities/match_entity.dart';
import '../../../team_generator/domain/entities/team_lineup_entity.dart';
import '../../../team_generator/presentation/bloc/team_generator_bloc.dart';
import '../../../team_generator/presentation/bloc/team_generator_state.dart';
import '../../../team_generator/presentation/widgets/select_match_for_lineup_sheet.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../widgets/create_match_dialog.dart';
import '../widgets/match_lineup_card.dart';
import '../widgets/withdrawal_reason_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _awaitingRoleSwitchFeedback = false;

  @override
  void initState() {
    super.initState();
    context.read<MatchesBloc>().add(const LoadMatchesRequested());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthBloc>().state is Unauthenticated) {
        try {
          context.go('/sign-in');
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDark = context.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isAdmin = user?.role == UserRole.admin;
    final userId = user?.id ?? 'guest';
    final userName = user?.displayName ?? 'مستخدم ضيف';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          _awaitingRoleSwitchFeedback = false;
          try {
            context.go('/sign-in');
          } catch (_) {}
        } else if (state is Authenticated && _awaitingRoleSwitchFeedback) {
          _awaitingRoleSwitchFeedback = false;
          context.showSuccessToast(
            state.isAdmin
                ? 'تم تفعيل وضع الكابتن (صلاحيات كاملة) 👑'
                : 'تم التبديل لوضع اللاعب العادي ⚽',
            duration: const Duration(seconds: 2),
          );
        }
      },
      child: KickoffResponsiveShell(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // User Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.meadowTint,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.turfGreenNeon.withValues(alpha: 0.4)
                                  : AppColors.primaryEmerald.withValues(alpha: 0.3),
                              width: 1.8,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildUserAvatar(user, userName, isDark),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAdmin
                                    ? 'أهلاً يا كابتن 👑'
                                    : 'مرحباً يا بطل 👋',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.turfGreenNeon
                                      : AppColors.primaryEmerald,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userName,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NotificationBellButton(size: 44),
                      const SizedBox(width: 8),
                      KickoffCircleButton(
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        onPressed: () => themeCubit.toggleTheme(),
                        size: 44,
                        tooltip: 'تغيير المظهر',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 8,
          ),
          children: [
            // Sleek Unified Role & Quick Actions Bar
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? (isDark
                                ? AppColors.turfGreenNeon.withValues(alpha: 0.16)
                                : AppColors.meadowTint)
                          : (isDark
                                ? AppColors.surfaceDarkElevated
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAdmin
                            ? (isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.turfGreen)
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin
                              ? Icons.workspace_premium_rounded
                              : Icons.sports_soccer_rounded,
                          size: 14,
                          color: isAdmin
                              ? (isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.turfGreenDark)
                              : (isDark
                                    ? AppColors.darkMuted
                                    : AppColors.slate),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isAdmin
                                ? 'مسؤول المجموعة (الكابتن)'
                                : 'لاعب في المجموعة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAdmin
                                  ? (isDark
                                        ? AppColors.turfGreenNeon
                                        : AppColors.turfGreenDark)
                                  : (isDark
                                        ? AppColors.darkText
                                        : AppColors.ink),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions row: Switch Role (Captain preview only) + Account Menu
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (authState is Authenticated &&
                          authState.canSwitchRolePreview) ...[
                        // Role switch pill (only for true Captain accounts)
                        InkWell(
                          onTap: () {
                            _awaitingRoleSwitchFeedback = true;
                            context.read<AuthBloc>().add(
                              const ToggleUserRoleRequested(),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDarkElevated
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.blueNeon
                                      : AppColors.blue,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isAdmin ? 'تجربة كـ لاعب' : 'تفعيل الكابتن',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Actions menu (Sign Out)
                      PopupMenuButton<String>(
                        tooltip: 'إجراءات الحساب والجلسة',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.surface,
                        elevation: 4,
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.slate,
                          ),
                        ),
                        onSelected: (val) {
                          if (val == 'logout') {
                            _confirmSignOut(context);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.ink,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Search bar without unnecessary filter button
            KickoffSearchField(showFilterButton: false, onChanged: (val) {}),

            const SizedBox(height: 18),

            // 3. Captain's Quick Control Center (Visible only to Admin)
            if (isAdmin) ...[
              KickoffMotionReveal(
                delay: const Duration(milliseconds: 50),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? AppColors.turfGreenNeon
                                            : AppColors.primaryEmerald)
                                        .withValues(alpha: isDark ? 0.16 : 0.11),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.shield_outlined,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.turfGreenNeon
                                        : AppColors.primaryEmerald,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Flexible(
                                  child: Text(
                                    'لوحة تحكم الكابتن',
                                    style: context.textTheme.titleSmall?.copyWith(
                                      color: context.colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const KickoffBadge(
                            label: 'صلاحيات الإدارة',
                            variant: BadgeVariant.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Quick Action Grid (Semantic Colored Squircles)
                      Row(
                        children: [
                          _buildAdminToolItem(
                            context: context,
                            icon: Icons.calendar_month_rounded,
                            label: 'حجز مباراة',
                            accentColor: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.primaryEmerald,
                            onTap: () => CreateMatchDialog.show(context),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildAdminToolItem(
                            context: context,
                            icon: Icons.person_add_rounded,
                            label: 'إضافة لاعب',
                            accentColor: isDark
                                ? AppColors.amberNeon
                                : AppColors.amberText,
                            onTap: () => AddPlayerDialog.show(context),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildAdminToolItem(
                            context: context,
                            icon: Icons.how_to_vote_rounded,
                            label: 'طرح تصويت',
                            accentColor: isDark
                                ? AppColors.blueNeon
                                : AppColors.blueAccent,
                            onTap: () {
                              CreatePollSheet.show(
                                context,
                                onCreatePoll: (poll) {
                                  context.read<PollsBloc>().add(
                                    CreatePollRequested(poll),
                                  );
                                },
                              );
                            },
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildAdminToolItem(
                            context: context,
                            icon: Icons.balance_rounded,
                            label: 'توزيع الفرق',
                            accentColor: isDark
                                ? AppColors.indigoNeon
                                : AppColors.indigoAccent,
                            onTap: () => _onTapTeamGenerator(context),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Featured Matchday Hero Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'المباراة القادمة المقترحة',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // TextButton(
                //   onPressed: () => context.go('/matches'),
                //   child: Text(context.l10n.seeAll),
                // ),
              ],
            ),
            const SizedBox(height: 8),

            BlocBuilder<MatchesBloc, MatchesState>(
              builder: (context, state) {
                MatchEntity? featuredMatch;
                if (state is MatchesLoaded && state.matches.isNotEmpty) {
                  featuredMatch = state.matches.first;
                }

                if (featuredMatch == null) {
                  return _buildSectionEmptyCard(
                    context: context,
                    icon: Icons.sports_soccer_rounded,
                    title: 'لا توجد مباريات مجدولة حالياً',
                    subtitle: isAdmin
                        ? 'اضغط على حجز مباراة في لوحة الكابتن لإنشاء موعد جديد وفتح التسجيل للمجموعة'
                        : 'لم يتم فتح تسجيل موعد المباراة القادمة بعد',
                  );
                }

                final title = featuredMatch.title;
                final stadium = featuredMatch.pitchName
                    .replaceAll(RegExp(r'\s*\(.*?\)'), '')
                    .trim();
                final location = featuredMatch.location
                    .split('•')
                    .first
                    .replaceAll(RegExp(r'-.*'), '')
                    .trim();
                final confirmed = featuredMatch.confirmedPlayers.length;
                final max = featuredMatch.maxPlayers;
                final waiting = featuredMatch.waitingList.length;
                final isUserIn = featuredMatch.confirmedPlayers.any(
                  (p) => p.playerId == userId,
                );

                final dateStr = DateFormat(
                  'EEEE d MMMM',
                  'ar',
                ).format(featuredMatch.matchDateTime);
                final timeStr = DateFormat(
                  'hh:mm a',
                  'ar',
                ).format(featuredMatch.matchDateTime);

                final targetMatch = featuredMatch;
                return KickoffHeroCard(
                  title: stadium,
                  subtitle: location,
                  matchTitle: title,
                  matchDate: dateStr,
                  matchTime: timeStr,
                  confirmedPlayers: confirmed,
                  maxPlayers: max,
                  waitingCount: waiting,
                  isUserRegistered: isUserIn,
                  isRegistrationOpen: targetMatch.isRegistrationOpen,
                  registrationOpensAt: targetMatch.registrationOpensAt,
                  onTap: () {
                    context.push('/match-details', extra: targetMatch);
                  },
                  onRsvpTap: () {
                    if (isUserIn) {
                      WithdrawalReasonDialog.show(
                        context,
                        match: targetMatch,
                        playerId: userId,
                        playerName: userName,
                      );
                    } else {
                      context.read<MatchesBloc>().add(
                        RegisterPlayerRequested(
                          matchId: targetMatch.id,
                          playerId: userId,
                          playerName: userName,
                          position: PlayerPosition.midfielder,
                        ),
                      );
                    }
                  },
                );
              },
            ),

            // Approved Match Lineup for the registered player (Displayed ONLY after official finalization)
            BlocBuilder<MatchesBloc, MatchesState>(
              builder: (context, matchState) {
                MatchEntity? match;
                if (matchState is MatchesLoaded &&
                    matchState.matches.isNotEmpty) {
                  match = matchState.matches.first;
                }
                final isUserIn =
                    match?.confirmedPlayers.any((p) => p.playerId == userId) ??
                    false;

                if (match == null || !isUserIn) return const SizedBox.shrink();

                return BlocBuilder<TeamGeneratorBloc, TeamGeneratorState>(
                  builder: (context, teamState) {
                    TeamLineupEntity? lineup;
                    if (teamState is TeamGeneratorSuccess) {
                      lineup = teamState.currentLineup;
                    }

                    // Only show the lineup card once the captain has officially generated & finalized it
                    if (lineup == null || !lineup.isFinalized) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: MatchLineupCard(
                        match: match!,
                        lineup: lineup,
                        currentUserId: userId,
                        currentUserName: userName,
                        onTap: () {
                          if (isAdmin) {
                            context.push('/team-generator', extra: match);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // 5. Weekly Schedule & Upcoming Bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'جدول الحجوزات والمباريات',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // TextButton(
                //   onPressed: () => context.go('/matches'),
                //   child: Text(context.l10n.seeAll),
                // ),
              ],
            ),
            const SizedBox(height: 8),

            BlocBuilder<MatchesBloc, MatchesState>(
              builder: (context, matchState) {
                if (matchState is MatchesLoaded &&
                    matchState.matches.isNotEmpty) {
                  final displayMatches = matchState.matches.take(3).toList();
                  return Column(
                    children: displayMatches.map((m) {
                      final isUserIn = m.confirmedPlayers.any(
                        (p) => p.playerId == userId,
                      );
                      final isWaiting = m.waitingList.any(
                        (p) => p.playerId == userId,
                      );
                      final isFull = m.confirmedPlayers.length >= m.maxPlayers;
                      final dateStr = DateFormat(
                        'EEEE d MMMM',
                        'ar',
                      ).format(m.matchDateTime);
                      final timeStr = DateFormat(
                        'hh:mm a',
                        'ar',
                      ).format(m.matchDateTime);

                      final activeAccent = isDark
                          ? AppColors.turfGreenNeon
                          : AppColors.primaryEmerald;
                      final cs = context.colorScheme;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: KickoffPressable(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  context.push('/match-details', extra: m),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isUserIn
                                        ? activeAccent
                                        : cs.outlineVariant,
                                    width: isUserIn ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: activeAccent.withValues(
                                          alpha: isDark ? 0.16 : 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.sports_soccer_rounded,
                                        size: 22,
                                        color: activeAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.title,
                                            style: context.textTheme.titleSmall
                                                ?.copyWith(
                                                  color: cs.onSurface,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.5,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '$dateStr • $timeStr',
                                            style: AppTypography.tabular(
                                              TextStyle(
                                                fontSize: 12,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    KickoffBadge(
                                      label: isUserIn
                                          ? 'مسجل ✓'
                                          : (isWaiting
                                                ? 'بالانتظار'
                                                : (isFull
                                                      ? 'مكتمل'
                                                      : 'متاح (${m.maxPlayers - m.confirmedPlayers.length})')),
                                      variant: isUserIn
                                          ? BadgeVariant.success
                                          : (isWaiting || isFull
                                                ? BadgeVariant.warning
                                                : BadgeVariant.neutral),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return _buildSectionEmptyCard(
                  context: context,
                  icon: Icons.calendar_month_rounded,
                  title: 'جدول المباريات فارغ حالياً',
                  subtitle: isAdmin
                      ? 'يمكنك حجز وتثبيت المباريات من لوحة الكابتن لتظهر في هذا الجدول'
                      : 'ستظهر هنا المواعيد والحجوزات القادمة فور إعلانها',
                );
              },
            ),
            const SizedBox(height: 18),

            // 6. Active Polls & MOTM Voting Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'استطلاعات الرأي والتصويت',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // TextButton(
                //   onPressed: () => context.push('/polls'),
                //   child: Text(context.l10n.seeAll),
                // ),
              ],
            ),
            const SizedBox(height: 8),

            BlocBuilder<PollsBloc, PollsState>(
              builder: (context, pollsState) {
                if (pollsState is PollsLoaded && pollsState.polls.isNotEmpty) {
                  final latestActive = pollsState.polls.first;
                  return PollCard(
                    poll: latestActive,
                    currentUserId: userId,
                    isAdmin: isAdmin,
                    onVoteOption: (option) {
                      context.read<PollsBloc>().add(
                        CastVoteRequested(
                          pollId: latestActive.id,
                          optionId: option.id,
                          userId: userId,
                        ),
                      );
                    },
                    onClosePoll: () {
                      context.read<PollsBloc>().add(
                        ClosePollRequested(latestActive.id),
                      );
                    },
                  );
                }
                return _buildSectionEmptyCard(
                  context: context,
                  icon: Icons.how_to_vote_rounded,
                  title: 'لا توجد استطلاعات نشطة حالياً',
                  subtitle: isAdmin
                      ? 'استخدم طرح تصويت من لوحة الكابتن لتحديد الموعد أو اختيار رجل المباراة'
                      : 'ستظهر هنا استطلاعات الكابتن للتصويت على القرارات والمواعيد',
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }

  void _onTapTeamGenerator(BuildContext context) {
    final matchesState = context.read<MatchesBloc>().state;
    final matches = matchesState is MatchesLoaded
        ? matchesState.matches
            .where((m) => m.status != MatchStatus.completed)
            .toList()
        : <MatchEntity>[];

    if (matches.isEmpty) {
      context.showWarningToast(
        'لا توجد حجوزات أو مباريات نشطة. يرجى إنشاء مباراة أولاً ⚽',
      );
      return;
    }

    if (matches.length == 1) {
      context.push('/team-generator', extra: matches.first);
      return;
    }

    SelectMatchForLineupSheet.show(
      context,
      matches: matches,
      onSelectMatch: (selectedMatch) {
        context.push('/team-generator', extra: selectedMatch);
      },
    );
  }

  Widget _buildAdminToolItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final cs = context.colorScheme;
    return Expanded(
      child: KickoffPressable(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: cs.outlineVariant, width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.16 : 0.11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 19,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserEntity? user, String userName, bool isDark) {
    return KickoffAvatar(
      photoUrl: user?.photoUrl,
      name: userName,
      size: 48,
      borderWidth: 0,
    );
  }

  Widget _buildSectionEmptyCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 26,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(dlgCtx).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
              context.go('/sign-in');
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

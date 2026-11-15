import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/motion/kickoff_motion.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../widgets/create_match_dialog.dart';
import '../widgets/match_result_card.dart';
import '../widgets/withdrawal_reason_dialog.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  int _selectedFilterIndex = 0; // 0: Upcoming, 1: Completed, 2: All

  @override
  void initState() {
    super.initState();
    context.read<MatchesBloc>().add(const LoadMatchesRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isAdmin = user?.role == UserRole.admin;
    final userId = user?.id ?? 'guest';
    final userName = user?.displayName ?? 'لاعب';

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: 'جدول المباريات والحجوزات',
          showBackButton: false,
          actions: [
            if (isAdmin)
              KickoffCircleButton(
                icon: Icons.add_rounded,
                tooltip: 'إنشاء مباراة جديدة',
                size: 40,
                onPressed: () => CreateMatchDialog.show(context),
              ),
          ],
        ),
        body: Column(
          children: [
            // Filter Chips Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(0, 'القادمة والحالية', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, 'النتائج والمكتملة', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, 'الكل', isDark),
                ],
              ),
            ),

            // Matches List
            Expanded(
              child: BlocConsumer<MatchesBloc, MatchesState>(
                listener: (context, state) {
                  if (state is MatchesLoaded && state.successMessage != null) {
                    context.showSuccessToast(state.successMessage!);
                  }
                },
                builder: (context, state) {
                  if (state is MatchesLoading) {
                    return const AppLoadingWidget(
                      message: 'جاري تحميل المباريات...',
                    );
                  }

                  if (state is MatchesErrorState) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context.read<MatchesBloc>().add(
                        const LoadMatchesRequested(),
                      ),
                    );
                  }

                  if (state is MatchesEmptyState) {
                    return _buildEmptyMatchesState(
                      context: context,
                      isAdmin: isAdmin,
                      title: state.message,
                      message: _selectedFilterIndex == 1
                          ? 'لا توجد نتائج سابقة مسجلة.'
                          : 'لم يتم فتح حجز أي مباراة جديدة بعد.',
                    );
                  }

                  if (state is MatchesLoaded) {
                    final allMatches = state.matches;
                    final filteredMatches = allMatches.where((m) {
                      if (_selectedFilterIndex == 0) {
                        return m.status != MatchStatus.completed &&
                            m.status != MatchStatus.cancelled;
                      } else if (_selectedFilterIndex == 1) {
                        return m.status == MatchStatus.completed;
                      }
                      return true;
                    }).toList();

                    if (filteredMatches.isEmpty) {
                      return _buildEmptyMatchesState(
                        context: context,
                        isAdmin: isAdmin,
                        title: 'لا توجد مباريات في هذه الفئة',
                        message: _selectedFilterIndex == 0
                            ? 'لم يتم فتح حجز أي مباراة جديدة بعد.'
                            : 'لا توجد نتائج سابقة مسجلة.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: filteredMatches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final match = filteredMatches[index];
                        if (match.status == MatchStatus.completed && match.result != null) {
                          return MatchResultCard(result: match.result!);
                        }
                        return _buildMatchCard(
                          context: context,
                          match: match,
                          isDark: isDark,
                          isAdmin: isAdmin,
                          userId: userId,
                          userName: userName,
                        );
                      },
                    );
                  }

                  return const AppLoadingWidget(
                    message: 'جاري تحميل المباريات...',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMatchesState({
    required BuildContext context,
    required bool isAdmin,
    required String title,
    required String message,
  }) {
    return AppEmptyStateWidget(
      title: title,
      message: message,
      actionLabel: isAdmin ? 'إنشاء مباراة الآن' : 'تحديث',
      onAction: () {
        if (isAdmin) {
          CreateMatchDialog.show(context);
        } else {
          context.read<MatchesBloc>().add(const LoadMatchesRequested());
        }
      },
    );
  }

  Widget _buildFilterChip(int index, String label, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    final cs = context.colorScheme;
    final accent = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
    return Expanded(
      child: KickoffPressable(
        child: GestureDetector(
          onTap: () => setState(() => _selectedFilterIndex = index),
          child: AnimatedContainer(
            duration: KickoffMotion.accessible(
              context,
              KickoffMotion.stateChange,
            ),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(alpha: isDark ? 0.18 : 0.11)
                  : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? accent : cs.outlineVariant,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? accent : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard({
    required BuildContext context,
    required MatchEntity match,
    required bool isDark,
    required bool isAdmin,
    required String userId,
    required String userName,
  }) {
    final isConfirmed = match.confirmedPlayers.any((p) => p.playerId == userId);
    final isWaiting = match.waitingList.any((p) => p.playerId == userId);
    final waitingIndex = isWaiting
        ? match.waitingList.indexWhere((p) => p.playerId == userId) + 1
        : 0;

    final confirmedCount = match.confirmedPlayers.length;
    final maxPlayers = match.maxPlayers;
    final isFull = confirmedCount >= maxPlayers;
    final progress = (confirmedCount / (maxPlayers > 0 ? maxPlayers : 18))
        .clamp(0.0, 1.0);

    final dateStr = DateFormat('EEEE d MMMM', 'ar').format(match.matchDateTime);
    final timeStr = DateFormat('hh:mm a', 'ar').format(match.matchDateTime);

    final cs = context.colorScheme;
    final activeAccent = cs.primary;
    final warningColor = isDark ? AppColors.amberNeon : AppColors.amber;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed ? activeAccent : cs.outlineVariant,
          width: isConfirmed ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title & Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  match.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              KickoffBadge(
                label: !match.isRegistrationOpen
                    ? 'يفتح الحجز ${DateFormat('hh:mm a', 'ar').format(match.registrationOpensAt!)}'
                    : isFull
                        ? 'مكتمل (قائمة انتظار)'
                        : 'مفتوح للتسجيل',
                variant: !match.isRegistrationOpen
                    ? BadgeVariant.info
                    : isFull
                        ? BadgeVariant.danger
                        : BadgeVariant.success,
              ),
              if (match.isRecurringWeekly) ...[
                const SizedBox(width: 6),
                const KickoffBadge(
                  label: 'أسبوعي 🔄',
                  variant: BadgeVariant.tactical,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Match Schedule Info
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 15,
                color: isDark
                    ? AppColors.turfGreenNeon
                    : AppColors.turfGreenDark,
              ),
              const SizedBox(width: 5),
              Text(
                '$dateStr • $timeStr',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Stadium & Location
          Row(
            children: [
              Icon(
                Icons.stadium_rounded,
                size: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${match.pitchName.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim()} • ${match.location.split('•').first.replaceAll(RegExp(r'-.*'), '').trim()}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Attendance Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اللاعبون: $confirmedCount / $maxPlayers (3 فرق)',
                style: AppTypography.tabular(
                  const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                match.waitingList.isNotEmpty
                    ? '${match.waitingList.length} في الانتظار'
                    : '${maxPlayers - confirmedCount} متاح',
                style: AppTypography.tabular(
                  TextStyle(
                    fontSize: 12,
                    color: match.waitingList.isNotEmpty
                        ? warningColor
                        : activeAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: cs.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? warningColor : activeAccent,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // User Registration Status Banner
          if (isConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.meadowTintDark : AppColors.meadowTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.turfGreen,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'أنت مسجل في التشكيلة الأساسية للمباراة ✓',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => WithdrawalReasonDialog.show(
                      context,
                      match: match,
                      playerId: userId,
                      playerName: userName,
                    ),
                    child: const Text(
                      'اعتذار ⚠️',
                      style: TextStyle(
                        color: AppColors.redText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isWaiting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom_rounded,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'أنت في قائمة الانتظار (الترتيب: #$waitingIndex)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<MatchesBloc>().add(
                        CancelRegistrationRequested(
                          matchId: match.id,
                          playerId: userId,
                        ),
                      );
                    },
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: AppColors.redText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (match.status == MatchStatus.upcoming ||
              match.status == MatchStatus.full)
            if (!match.isRegistrationOpen)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: isDark ? AppColors.blueNeon : AppColors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'يبدأ الحجز الساعة ${DateFormat('hh:mm a', 'ar').format(match.registrationOpensAt!)} ⏳',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFull
                      ? (isDark
                          ? AppColors.amber.withValues(alpha: 0.16)
                          : AppColors.amberTint)
                      : cs.primary,
                  foregroundColor: isFull
                      ? (isDark ? AppColors.amberNeon : AppColors.amberText)
                      : Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isFull
                        ? BorderSide(
                            color: AppColors.amber.withValues(alpha: 0.45),
                          )
                        : BorderSide.none,
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<MatchesBloc>().add(
                    RegisterPlayerRequested(
                      matchId: match.id,
                      playerId: userId,
                      playerName: userName,
                      position: PlayerPosition.midfielder,
                    ),
                  );
                },
                icon: Icon(
                  isFull
                      ? Icons.hourglass_top_rounded
                      : Icons.sports_soccer_rounded,
                  size: 20,
                ),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isFull
                        ? 'الانضمام لقائمة الانتظار'
                        : 'حجز مقعد والمشاركة في المباراة',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

          const SizedBox(height: 10),

          // Secondary Action Buttons Row
          Row(
            children: [
              // Details Button
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: BorderSide(color: cs.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        context.push('/match-details', extra: match),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'التشكيلة والتفاصيل',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Admin Specific Quick Tools
              if (isAdmin && match.status != MatchStatus.completed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: cs.primary.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      onPressed: () =>
                          context.push('/team-generator', extra: match),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.balance_rounded, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'توليد الفرق',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(
                    Icons.scoreboard_rounded,
                    color: activeAccent,
                  ),
                  tooltip: 'تسجيل النتيجة',
                  onPressed: () => context.push('/record-result', extra: match),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

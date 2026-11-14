import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/player_withdrawal_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../widgets/match_result_card.dart';
import '../widgets/match_roster_view.dart';
import '../widgets/match_status_badge.dart';
import '../widgets/withdrawal_reason_dialog.dart';

class MatchDetailsPage extends StatefulWidget {
  final String? matchId;

  const MatchDetailsPage({super.key, this.matchId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.matchId != null) {
      context.read<MatchesBloc>().add(SelectMatchRequested(widget.matchId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState is Authenticated && authState.user.role == UserRole.admin;

    return KickoffResponsiveShell(
      child: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchesLoaded && state.successMessage != null) {
            context.showSuccessToast(state.successMessage!);
          } else if (state is MatchesErrorState) {
            context.showErrorToast(state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Scaffold(
              body: AppLoadingWidget(message: 'جاري تحميل تفاصيل المباراة...'),
            );
          }

          if (state is MatchesLoaded) {
            final match =
                state.selectedMatch ??
                (state.matches.isNotEmpty ? state.matches.first : null);

            if (match != null) {
              return Scaffold(
                appBar: KickoffTopBar(
                  title: context.l10n.isArabic
                      ? 'تفاصيل المباراة الأسبوعية'
                      : 'Match Details',
                  actions: [
                    if (isAdmin) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: KickoffCircleButton(
                          icon: Icons.sports_score_rounded,
                          onPressed: () =>
                              context.push('/record-result', extra: match),
                          size: 40,
                          tooltip: 'تسجيل النتيجة الرسمية',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: KickoffCircleButton(
                          icon: Icons.auto_awesome_rounded,
                          onPressed: () =>
                              context.push('/team-generator', extra: match),
                          size: 40,
                          tooltip: 'توليد الفرق الذكية',
                        ),
                      ),
                    ],
                    KickoffCircleButton(
                      icon: _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isFavorite ? Colors.red : null,
                      onPressed: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      size: 40,
                      tooltip: 'المفضلة',
                    ),
                  ],
                ),
                body: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.horizontalPadding,
                    vertical: 12.0,
                  ),
                  children: [
                    // Hero Stadium Visual (clean white surface)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: context.colorScheme.outlineVariant,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stadium_rounded,
                                      size: 62,
                                      color: context.colorScheme.primary
                                          .withValues(alpha: 0.85),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      match.pitchName,
                                      style: TextStyle(
                                        color: context.colorScheme.onSurface,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Floating distance pill
                        Positioned(
                          top: 14,
                          left: context.isRtl ? 14 : null,
                          right: context.isRtl ? null : 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircular,
                              ),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me_rounded,
                                  size: 13,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '0.8 km',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: context.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Status Badge on bottom-start
                        Positioned(
                          bottom: 14,
                          left: context.isRtl ? null : 14,
                          right: context.isRtl ? 14 : null,
                          child: MatchStatusBadge(
                            status: match.status,
                            availableSpots: match.availableSpots,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Title & Fee Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.title,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      match.location,
                                      style: context.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${match.maxPlayers} لاعباً',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),

                    // Match Result Card (if completed/recorded)
                    if (match.result != null) ...[
                      const SizedBox(height: 18),
                      MatchResultCard(result: match.result!),
                    ],

                    const SizedBox(height: 20),

                    // Pitch Dimensions and Surface Card
                    KickoffCard(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDarkElevated
                                  : AppColors.canvasLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.straighten_rounded,
                              color: isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.turfGreenDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أبعاد ونوع الملعب',
                                  style: context.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${match.pitchDimensions} • ${match.courtType}',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Smart Team Generator CTA Card (Admin/Captain Only)
                    if (isAdmin) ...[
                      KickoffCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () =>
                            context.push('/team-generator', extra: match),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? AppColors.indigoNeon
                                        : AppColors.indigoAccent)
                                    .withValues(alpha: isDark ? 0.16 : 0.11),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: isDark
                                    ? AppColors.indigoNeon
                                    : AppColors.indigoAccent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المولد الذكي للفرق (صلاحيات الكابتن)',
                                    style: context.textTheme.titleSmall?.copyWith(
                                      color: context.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'توزيع تكتيكي عادل ومتكافئ للقوى والمراكز',
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_left_rounded,
                              size: 18,
                              color: context.colorScheme.outline,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // Auto Lineup Status Banner
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.primaryEmerald)
                            .withValues(alpha: isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.primaryEmerald)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            match.isAutoLineupEnabled
                                ? Icons.auto_awesome_rounded
                                : Icons.pan_tool_outlined,
                            color: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.primaryEmerald,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              match.isAutoLineupEnabled
                                  ? 'توليد الفرق الذكي التلقائي: يتم توزيع الفرق الثلاثة تكتيكياً قبل المباراة بساعة مع إشعار للمشاركين ⏰'
                                  : 'التوزيع اليدوي مفعل: الكابتن سيقوم باختيار وتوزيع التشكيلات يدوياً ✍️',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.turfGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Confirmed Squad & Waiting List
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final user = authState is Authenticated ? authState.user : null;
                        final currentUserId = user?.id ?? 'admin_1';
                        final currentUserName = user?.displayName ?? 'لاعب';

                        return MatchRosterView(
                          match: match,
                          currentUserId: currentUserId,
                          isAdmin: isAdmin,
                          onCancelMyRegistration: () {
                            WithdrawalReasonDialog.show(
                              context,
                              match: match,
                              playerId: currentUserId,
                              playerName: currentUserName,
                            );
                          },
                        );
                      },
                    ),

                    // Admin & Team Section: Withdrawn Players & Excuses Record
                    if (match.withdrawals.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildWithdrawalsRecord(context, match.withdrawals, isDark),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),

                // Pinned Bottom Action Button
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.horizontalPadding,
                      vertical: 12.0,
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final user = authState is Authenticated ? authState.user : null;
                        final currentUserId = user?.id ?? 'admin_1';
                        final currentUserName = user?.displayName ?? 'لاعب';
                        final isRegistered = match.isPlayerRegistered(
                          currentUserId,
                        );
                        final reg = match.getPlayerRegistration(currentUserId);

                        if (isRegistered) {
                          final isWaiting = reg?.isWaiting ?? false;
                          return KickoffActionButton(
                            label: isWaiting
                                ? 'أنت في قائمة الانتظار #${reg?.queuePosition ?? 1} (اعتذار)'
                                : 'أنت مسجل أساسي ⚽ (اعتذار وانسحاب)',
                            circleColor: isWaiting
                                ? AppColors.amberText
                                : AppColors.redText,
                            customIcon: Icons.cancel_rounded,
                            onPressed: () {
                              WithdrawalReasonDialog.show(
                                context,
                                match: match,
                                playerId: currentUserId,
                                playerName: currentUserName,
                              );
                            },
                          );
                        }

                        final label = match.isSquadFull
                            ? 'التسجيل في قائمة الانتظار ⏳'
                            : 'تسجيل الحضور في التشكيلة الأساسية ⚽';

                        return KickoffActionButton(
                          label: label,
                          onPressed: () =>
                              context.push('/reserve', extra: match),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
          }

          return Scaffold(
            appBar: KickoffTopBar(
              title: context.l10n.isArabic
                  ? 'تفاصيل المباراة'
                  : 'Match Details',
            ),
            body: AppErrorWidget(
              message: 'تعذر تحميل بيانات المباراة',
              onRetry: () =>
                  context.read<MatchesBloc>().add(const LoadMatchesRequested()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalsRecord(
    BuildContext context,
    List<PlayerWithdrawalEntity> withdrawals,
    bool isDark,
  ) {
    final cs = context.colorScheme;
    final crimson = isDark ? AppColors.redNeon : AppColors.redText;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: crimson.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  color: crimson,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'سجل الاعتذارات والمنسحبين (${withdrawals.length})',
                style: context.textTheme.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...withdrawals.map((w) {
            final timeStr = DateFormat('hh:mm a • d/M', 'ar').format(w.withdrawnAt);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant, width: 1.0),
              ),
              child: Row(
                children: [
                  KickoffAvatar(
                    photoUrl: null,
                    name: w.playerName,
                    size: 34,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.playerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (w.customNote != null && w.customNote!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            w.customNote!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.redText.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          w.reason,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.redText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

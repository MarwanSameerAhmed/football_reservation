import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/entities/poll_option_entity.dart';
import 'poll_option_tile.dart';
import 'poll_type_badge.dart';

/// Creative Matchday Poll Card with real-time voting progress, winner highlights,
/// participant indicators, and Captain admin controls.
class PollCard extends StatelessWidget {
  final PollEntity poll;
  final String currentUserId;
  final bool isAdmin;
  final ValueChanged<PollOptionEntity>? onVoteOption;
  final VoidCallback? onClosePoll;

  const PollCard({
    super.key,
    required this.poll,
    required this.currentUserId,
    this.isAdmin = false,
    this.onVoteOption,
    this.onClosePoll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final winning = (poll.isClosed || poll.hasExpired)
        ? poll.winningOption
        : null;
    final userHasVoted = poll.hasUserVoted(currentUserId);

    return KickoffCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Type badge + Live Status pill + Admin Close Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              PollTypeBadge(type: poll.type),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KickoffBadge(
                    label: poll.isLockedUntilMatchEnds
                        ? 'مؤجل لنهاية المباراة ⏳'
                        : (poll.isActive ? 'مباشر ⏳' : 'محسوم 🏆'),
                    variant: poll.isLockedUntilMatchEnds
                        ? BadgeVariant.warning
                        : (poll.isActive
                              ? BadgeVariant.success
                              : BadgeVariant.neutral),
                  ),
                  if (isAdmin && poll.isActive && onClosePoll != null) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(
                        Icons.lock_clock_rounded,
                        size: 18,
                        color: AppColors.redText,
                      ),
                      tooltip: 'إنهاء واعتماد النتيجة',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onClosePoll,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Poll Title
          Text(
            poll.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          // Poll Description / Context
          if (poll.description != null && poll.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              poll.description!,
              style: context.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          // Match Reference Banner
          if (poll.matchDetails != null || poll.matchId != null) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                final matchAccent = isDark ? AppColors.turfGreenNeon : cs.primary;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: matchAccent.withValues(alpha: isDark ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: matchAccent.withValues(alpha: isDark ? 0.28 : 0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_soccer_rounded,
                        size: 15,
                        color: matchAccent,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'خاص بمباراة: ${poll.matchDetails ?? "مباراة الأسبوع"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: matchAccent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 14),

          // Options or Locked Waiting Notice
          if (poll.isLockedUntilMatchEnds) ...[
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(
                      alpha: isDark ? 0.55 : 0.65,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_clock_rounded,
                        color: AppColors.amberText,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التصويت مغلق لحين نهاية المباراة',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'هذا الاستطلاع مخصص لتحديد رجل المباراة، وسيتم فتحه للتصويت بعد انتهاء اللقاء وتسجيل النتيجة.',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            // Options List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: poll.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final option = poll.options[index];
                final pct = poll.optionPercentage(option);
                final isVotedByMe = option.hasVoted(currentUserId);
                final isWinner = winning?.id == option.id;

                return PollOptionTile(
                  option: option,
                  percentage: pct,
                  isSelectedByMe: isVotedByMe,
                  isWinner: isWinner,
                  isClosed: !poll.isActive,
                  onTap: onVoteOption != null
                      ? () => onVoteOption!(option)
                      : null,
                );
              },
            ),
          ],
          const SizedBox(height: 12),

          // Bottom Info Bar: Total Votes + User Status
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.turfGreenNeon
                        : AppColors.turfGreenDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${poll.totalVotes} مشاركاً',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: userHasVoted
                      ? (isDark
                            ? AppColors.turfGreen.withValues(alpha: 0.15)
                            : AppColors.meadowTint)
                      : (isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.canvasLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  userHasVoted ? 'تم تسجيل صوتك ✓' : 'اضغط للتصويت',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: userHasVoted
                        ? (isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.turfGreenDark)
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

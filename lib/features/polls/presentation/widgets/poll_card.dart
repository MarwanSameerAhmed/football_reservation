import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/entities/poll_option_entity.dart';
import 'poll_option_tile.dart';
import 'poll_type_badge.dart';

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
    final winning = (poll.isClosed || poll.hasExpired)
        ? poll.winningOption
        : null;

    return KickoffCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Type badge & Status badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              PollTypeBadge(type: poll.type),
              KickoffBadge(
                label: poll.isActive ? 'متاح للتصويت ⏳' : 'التصويت مغلق ✓',
                variant: poll.isActive
                    ? BadgeVariant.success
                    : BadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            poll.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // Description (if present)
          if (poll.description != null && poll.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(poll.description!, style: context.textTheme.bodySmall),
          ],
          const SizedBox(height: 14),

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
          const SizedBox(height: 12),

          // Footer info & actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'إجمالي المشاركين: ${poll.totalVotes} صوت',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              if (isAdmin && poll.isActive && onClosePoll != null)
                TextButton.icon(
                  onPressed: onClosePoll,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(
                    Icons.lock_clock_outlined,
                    size: 16,
                    color: AppColors.redText,
                  ),
                  label: Text(
                    'إنهاء واعتماد النتيجة',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.redText,
                      fontWeight: FontWeight.bold,
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

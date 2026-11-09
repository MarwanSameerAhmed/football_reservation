import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../players/presentation/widgets/player_position_badge.dart';
import '../../domain/entities/match_entity.dart';

class MatchRosterView extends StatelessWidget {
  final MatchEntity match;
  final String? currentUserId;
  final VoidCallback? onCancelMyRegistration;

  const MatchRosterView({
    super.key,
    required this.match,
    this.currentUserId,
    this.onCancelMyRegistration,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confirmed Squad Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التشكيلة الأساسية المؤكدة (${match.confirmedPlayers.length}/${match.maxPlayers})',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            KickoffBadge(
              label: '${match.availableSpots} شاغر',
              variant: match.availableSpots > 0
                  ? BadgeVariant.success
                  : BadgeVariant.warning,
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (match.confirmedPlayers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Center(
              child: Text('لم يسجل أي لاعب في التشكيلة الأساسية بعد.'),
            ),
          )
        else
          ...List.generate(match.confirmedPlayers.length, (index) {
            final reg = match.confirmedPlayers[index];
            final isMe = reg.playerId == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: isMe
                      ? (isDark ? AppColors.turfGreenNeon : AppColors.turfGreen)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isMe ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.canvasLight,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            reg.playerName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          const KickoffBadge(
                            label: 'أنت',
                            variant: BadgeVariant.success,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PlayerPositionBadge(position: reg.playerPosition),
                  if (isMe && onCancelMyRegistration != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                        color: AppColors.redText,
                      ),
                      tooltip: 'إلغاء الحضور',
                      onPressed: onCancelMyRegistration,
                    ),
                  ],
                ],
              ),
            );
          }),

        const SizedBox(height: 24),

        // Waiting List Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قائمة الانتظار (${match.waitingList.length})',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const KickoffBadge(
              label: 'تصعيد تلقائي',
              variant: BadgeVariant.neutral,
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (match.waitingList.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Center(child: Text('قائمة الانتظار فارغة حالياً.')),
          )
        else
          ...List.generate(match.waitingList.length, (index) {
            final reg = match.waitingList[index];
            final isMe = reg.playerId == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF241C12)
                    : AppColors.amberTint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: isDark ? const Color(0xFF422E18) : AppColors.amberTint,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amberText.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${reg.queuePosition ?? (index + 1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amberText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reg.playerName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PlayerPositionBadge(position: reg.playerPosition),
                  if (isMe && onCancelMyRegistration != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                        color: AppColors.redText,
                      ),
                      tooltip: 'إلغاء الانتظار',
                      onPressed: onCancelMyRegistration,
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}

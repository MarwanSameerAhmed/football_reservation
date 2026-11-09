import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/presentation/widgets/player_position_badge.dart';

class TeamPlayerTile extends StatelessWidget {
  final PlayerEntity player;
  final bool isSelectedForSwap;
  final VoidCallback? onTap;

  const TeamPlayerTile({
    super.key,
    required this.player,
    this.isSelectedForSwap = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelectedForSwap
              ? (isDark
                    ? AppColors.turfGreenDark.withValues(alpha: 0.25)
                    : AppColors.meadowTint)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelectedForSwap
                ? AppColors.turfGreen
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelectedForSwap ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar / Number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelectedForSwap
                    ? AppColors.turfGreen
                    : (isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.canvasLight),
              ),
              child: Center(
                child: isSelectedForSwap
                    ? const Icon(
                        Icons.swap_horiz_rounded,
                        size: 18,
                        color: AppColors.darkSlate,
                      )
                    : Text(
                        player.name.isNotEmpty ? player.name[0] : '?',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: isDark ? Colors.white : AppColors.darkSlate,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      PlayerPositionBadge(
                        position: player.primaryPosition,
                        showFullLabel: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDarkElevated
                    : AppColors.canvasLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.amberText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    player.skills.overallScore.toString(),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

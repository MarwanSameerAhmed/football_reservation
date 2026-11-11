import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/presentation/widgets/player_position_badge.dart';

class TeamPlayerTile extends StatelessWidget {
  final PlayerEntity player;
  final bool isSelectedForSwap;
  final bool isCaptain;
  final int? goalkeeperOrder;
  final VoidCallback? onTap;

  const TeamPlayerTile({
    super.key,
    required this.player,
    this.isSelectedForSwap = false,
    this.isCaptain = false,
    this.goalkeeperOrder,
    this.onTap,
  });

  Widget _buildAvatarContent(bool isDark) {
    final photo = player.photoUrl?.trim();
    if (photo != null && photo.isNotEmpty) {
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return ClipOval(
          child: Image.network(
            photo,
            fit: BoxFit.cover,
            width: 34,
            height: 34,
            errorBuilder: (_, __, ___) => _buildFallbackInitial(isDark),
          ),
        );
      }
      return Center(child: Text(photo, style: const TextStyle(fontSize: 16)));
    }
    return _buildFallbackInitial(isDark);
  }

  Widget _buildFallbackInitial(bool isDark) {
    return Center(
      child: Text(
        player.name.isNotEmpty ? player.name[0] : '⚽',
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.darkSlate,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

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
              ? (isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald)
                    .withValues(alpha: isDark ? 0.18 : 0.10)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelectedForSwap
                ? (isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald)
                : isCaptain
                ? AppColors.amberText.withValues(alpha: 0.75)
                : Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: isSelectedForSwap ? 2 : (isCaptain ? 1.5 : 1),
          ),
        ),
        child: Row(
          children: [
            // Avatar with optional Captain armband badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelectedForSwap
                        ? AppColors.turfGreen
                        : (isDark
                              ? AppColors.surfaceDarkElevated
                              : AppColors.canvasLight),
                    border: Border.all(
                      color: isCaptain
                          ? AppColors.amberText
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: isSelectedForSwap
                      ? Center(
                          child: Icon(
                            Icons.swap_horiz_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.primaryEmerald,
                          ),
                        )
                      : _buildAvatarContent(isDark),
                ),
                if (isCaptain)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.amberText,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 9)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),

            // Name + Badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isCaptain) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amberText.withValues(
                              alpha: isDark ? 0.16 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.amberText.withValues(
                                alpha: isDark ? 0.35 : 0.28,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('👑', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 3),
                              Text(
                                'كابتن',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.amberText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PlayerPositionBadge(
                        position: player.primaryPosition,
                        showFullLabel: false,
                      ),
                      if (goalkeeperOrder != null && goalkeeperOrder! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.turfGreenNeon
                                        : AppColors.primaryEmerald)
                                    .withValues(alpha: isDark ? 0.14 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  (isDark
                                          ? AppColors.turfGreenNeon
                                          : AppColors.primaryEmerald)
                                      .withValues(alpha: isDark ? 0.30 : 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🧤', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                'حارس #$goalkeeperOrder',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.turfGreenNeon
                                      : AppColors.primaryEmerald,
                                ),
                              ),
                            ],
                          ),
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
                color: Theme.of(context).colorScheme.surfaceContainer,
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

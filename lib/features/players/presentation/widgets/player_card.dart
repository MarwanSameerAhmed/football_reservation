import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/motion/kickoff_motion.dart';
import '../../../../core/presentation/widgets/kickoff_avatar.dart';
import '../../domain/entities/player_entity.dart';

/// Executive Athletic Player Card adhering to M3 Surface Hierarchy & Tabular Numerals.
class PlayerCard extends StatelessWidget {
  final PlayerEntity player;
  final VoidCallback? onTap;

  const PlayerCard({super.key, required this.player, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final pos = player.primaryPosition;
    final ovrRating = player.skills.overallRating;

    return Semantics(
      button: onTap != null,
      label: '${player.name}, $ovrRating تقييم, ${pos.labelArabic}',
      child: KickoffPressable(
        enabled: onTap != null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant,
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // 1. Clean Circular Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainer,
                      border: Border.all(
                        color: cs.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildAvatarContent(isDark),
                  ),
                  const SizedBox(width: 12),

                  // 2. Player Information (Name, Nickname, Position & Quick Record)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                player.name,
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (player.nickname != null &&
                                player.nickname!.trim().isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '(${player.nickname!.trim()})',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),

                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                pos.labelArabic,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              '${player.matchesPlayed} مباراة • ${player.goals} هدف',
                              style: AppTypography.tabular(
                                TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 3. Executive Tabular OVR Rating Pill & Chevron
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.amberNeon
                              : AppColors.amberText)
                          .withValues(alpha: isDark ? 0.14 : 0.09),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (isDark
                                ? AppColors.amberNeon
                                : AppColors.amberText)
                            .withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.amberNeon
                              : AppColors.amberText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$ovrRating',
                          style: AppTypography.tabular(
                            TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: cs.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(bool isDark) {
    return KickoffAvatar(
      photoUrl: player.photoUrl,
      name: player.name,
      size: 48,
      borderWidth: 0,
    );
  }
}

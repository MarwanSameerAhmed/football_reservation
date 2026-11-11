import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../domain/entities/generated_team_entity.dart';
import 'team_player_tile.dart';

class TeamCard extends StatelessWidget {
  final GeneratedTeamEntity team;
  final PlayerEntity? selectedPlayerForSwap;
  final ValueChanged<PlayerEntity> onPlayerTap;
  final Color accentColor;

  const TeamCard({
    super.key,
    required this.team,
    this.selectedPlayerForSwap,
    required this.onPlayerTap,
    this.accentColor = AppColors.turfGreen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final captain = team.captain;

    return KickoffCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              KickoffBadge(
                label: '${team.players.length} لاعبين',
                variant: BadgeVariant.neutral,
              ),
              const SizedBox(width: 6),
              KickoffBadge(
                label: 'معدل ${team.averageRating.toStringAsFixed(1)}',
                variant: BadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thoughtful Captain announcement banner
          if (captain != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amberText.withValues(
                  alpha: isDark ? 0.14 : 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.amberText.withValues(
                    alpha: isDark ? 0.30 : 0.25,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'كابتن الفريق: ${captain.name} (اختيار مدروس بناءً على الأقدمية والتقييم)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amberText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Goalkeeper Rotation Sequence
          if (team.goalkeeperRotation.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark
                        ? AppColors.turfGreenNeon
                        : AppColors.primaryEmerald)
                    .withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark
                          ? AppColors.turfGreenNeon
                          : AppColors.primaryEmerald)
                      .withValues(alpha: isDark ? 0.28 : 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🧤', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'ترتيب تناوب الحراسة (توليد عشوائي عادل)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.primaryEmerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: team.goalkeeperRotationPlayers.map((p) {
                        final order = team.getGoalkeeperOrder(p.id);
                        final isLast = order == team.players.length;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDarkElevated
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '#$order',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.turfGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.darkSlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) ...[
                              const SizedBox(width: 4),
                              Icon(
                                context.isRtl
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Players list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: team.players.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final player = team.players[index];
              final isSelected = selectedPlayerForSwap?.id == player.id;
              final isCaptain = team.isCaptain(player.id);
              final gkOrder = team.getGoalkeeperOrder(player.id);

              return TeamPlayerTile(
                player: player,
                isSelectedForSwap: isSelected,
                isCaptain: isCaptain,
                goalkeeperOrder: gkOrder > 0 ? gkOrder : null,
                onTap: () => onPlayerTap(player),
              );
            },
          ),
        ],
      ),
    );
  }
}

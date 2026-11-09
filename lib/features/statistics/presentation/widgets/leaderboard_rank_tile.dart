import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../players/presentation/widgets/player_position_badge.dart';
import '../../domain/entities/player_stats_entity.dart';

class LeaderboardRankTile extends StatelessWidget {
  final PlayerStatsEntity player;
  final int rank;
  final StatisticsCategory category;

  const LeaderboardRankTile({
    super.key,
    required this.player,
    required this.rank,
    required this.category,
  });

  String _formatMetric() {
    final count = switch (category) {
      StatisticsCategory.goals => player.goals,
      StatisticsCategory.assists => player.assists,
      StatisticsCategory.cleanSheets => player.cleanSheets,
      StatisticsCategory.motm => player.motmAwards,
    };
    return '$count ${category.metricUnitArabic}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final rankColor = switch (rank) {
      1 => const Color(0xFFEAB308),
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFB45309),
      _ => isDark ? AppColors.textSecondaryLight : AppColors.textSecondaryLight,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? rankColor.withValues(alpha: 0.15)
                  : (isDark
                        ? AppColors.surfaceDarkElevated
                        : AppColors.canvasLight),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Player Name & Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    PlayerPositionBadge(
                      position: player.position,
                      showFullLabel: false,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${player.matchesPlayed} مباريات • ${player.winRate.toStringAsFixed(0)}% فوز',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Primary Stat Metric Chip
          KickoffBadge(label: _formatMetric(), variant: BadgeVariant.success),
        ],
      ),
    );
  }
}

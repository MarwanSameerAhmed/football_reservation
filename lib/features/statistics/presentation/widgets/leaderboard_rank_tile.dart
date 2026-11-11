import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_avatar.dart';
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

    final cs = Theme.of(context).colorScheme;
    final rankColor = switch (rank) {
      1 => AppColors.amberText,
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFB45309),
      _ => cs.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.7),
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
                  : cs.surfaceContainer,
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
          const SizedBox(width: 8),

          // Player Avatar (Photo or Preset)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainer,
              border: Border.all(
                color: rank <= 3
                    ? rankColor.withValues(alpha: 0.6)
                    : cs.outlineVariant.withValues(alpha: 0.7),
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildTileAvatar(player, isDark),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerPositionBadge(
                        position: player.position,
                        showFullLabel: false,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${player.matchesPlayed} مباريات • ${player.winRate.toStringAsFixed(0)}% فوز',
                        maxLines: 1,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildTileAvatar(PlayerStatsEntity player, bool isDark) {
    return KickoffAvatar(
      photoUrl: player.photoUrl,
      name: player.playerName,
      size: 36,
      borderWidth: 0,
    );
  }
}

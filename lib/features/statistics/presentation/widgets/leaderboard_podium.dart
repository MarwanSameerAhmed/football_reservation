import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/player_stats_entity.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<PlayerStatsEntity> topThree;
  final StatisticsCategory category;

  const LeaderboardPodium({
    super.key,
    required this.topThree,
    required this.category,
  });

  String _formatMetric(PlayerStatsEntity player) {
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
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          if (second != null)
            Expanded(
              child: _buildPodiumStep(
                context,
                player: second,
                rank: 2,
                height: 105,
                color: const Color(0xFF94A3B8),
                metric: _formatMetric(second),
              ),
            ),
          const SizedBox(width: 8),

          // 1st Place (Gold - Tallest in Center)
          if (first != null)
            Expanded(
              child: _buildPodiumStep(
                context,
                player: first,
                rank: 1,
                height: 135,
                color: const Color(0xFFEAB308),
                metric: _formatMetric(first),
                isFirst: true,
              ),
            ),
          const SizedBox(width: 8),

          // 3rd Place (Bronze)
          if (third != null)
            Expanded(
              child: _buildPodiumStep(
                context,
                player: third,
                rank: 3,
                height: 85,
                color: const Color(0xFFB45309),
                metric: _formatMetric(third),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep(
    BuildContext context, {
    required PlayerStatsEntity player,
    required int rank,
    required double height,
    required Color color,
    required String metric,
    bool isFirst = false,
  }) {
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with medal crown
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 50 : 42,
              height: isFirst ? 50 : 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.surfaceDarkElevated
                    : AppColors.canvasLight,
                border: Border.all(color: color, width: 2.5),
              ),
              child: Center(
                child: Text(
                  player.playerName.isNotEmpty ? player.playerName[0] : '?',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkSlate,
                  ),
                ),
              ),
            ),
            if (isFirst)
              const Positioned(
                top: -14,
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 20,
                  color: Color(0xFFEAB308),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Player Name
        Text(
          player.playerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),

        // Metric Pill
        Text(
          metric,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.turfGreenNeon : AppColors.turfGreenDark,
          ),
        ),
        const SizedBox(height: 8),

        // Pedestal block
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDarkElevated
                : color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

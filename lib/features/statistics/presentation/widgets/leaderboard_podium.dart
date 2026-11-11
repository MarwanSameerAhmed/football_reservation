import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_avatar.dart';
import '../../domain/entities/player_stats_entity.dart';

/// Highly creative 3D-styled Olympic/FIFA Podium for top 3 football leaders.
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

    final isDark = context.isDarkMode;

    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.military_tech_rounded,
                color: AppColors.amberText,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'منصة التتويج الشرفية',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.turfGreenNeon
                        : AppColors.primaryEmerald,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 3-Pillar Podium Row
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 320,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place (Silver) - Right in RTL
                  if (second != null)
                    Expanded(
                      child: _buildPodiumStep(
                        context,
                        player: second,
                        rank: 2,
                        height: 105,
                        primaryColor: const Color(0xFF94A3B8),
                        gradientColors: [
                          const Color(0xFF94A3B8),
                          const Color(0xFF64748B),
                        ],
                        metric: _formatMetric(second),
                        medalIcon: Icons.workspace_premium_rounded,
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: 8),

                  // 1st Place (Gold) - Center and Tallest
                  if (first != null)
                    Expanded(
                      child: _buildPodiumStep(
                        context,
                        player: first,
                        rank: 1,
                        height: 145,
                        primaryColor: const Color(0xFFF59E0B),
                        gradientColors: [
                          const Color(0xFFFBBF24),
                          const Color(0xFFD97706),
                        ],
                        metric: _formatMetric(first),
                        isFirst: true,
                        medalIcon: Icons.emoji_events_rounded,
                      ),
                    ),

                  const SizedBox(width: 8),

                  // 3rd Place (Bronze) - Left in RTL
                  if (third != null)
                    Expanded(
                      child: _buildPodiumStep(
                        context,
                        player: third,
                        rank: 3,
                        height: 80,
                        primaryColor: const Color(0xFFB45309),
                        gradientColors: [
                          const Color(0xFFD97706),
                          const Color(0xFF92400E),
                        ],
                        metric: _formatMetric(third),
                        medalIcon: Icons.military_tech_rounded,
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
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
    required Color primaryColor,
    required List<Color> gradientColors,
    required String metric,
    required IconData medalIcon,
    bool isFirst = false,
  }) {
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with Medal Trophy
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 58 : 46,
              height: isFirst ? 58 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.2),
                    primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: primaryColor,
                  width: isFirst ? 2.5 : 2.0,
                ),
                boxShadow: isFirst
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildPodiumAvatar(player, isFirst, isDark),
            ),
            // Crown or Medal atop avatar
            Positioned(
              top: isFirst ? -14 : -10,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  medalIcon,
                  size: isFirst ? 14 : 11,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Player Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            player.playerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isFirst ? 13 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Metric Badge
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metric,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : primaryColor,
              ),
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 3D Pedestal Step
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: isFirst ? 28 : 22,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              if (isFirst)
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.amberText,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumAvatar(
    PlayerStatsEntity player,
    bool isFirst,
    bool isDark,
  ) {
    return KickoffAvatar(
      photoUrl: player.photoUrl,
      name: player.playerName,
      size: isFirst ? 58 : 46,
      borderWidth: 0,
    );
  }
}

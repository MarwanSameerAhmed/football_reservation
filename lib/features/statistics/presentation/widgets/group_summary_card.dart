import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../domain/entities/group_leaderboard_entity.dart';

class GroupSummaryCard extends StatelessWidget {
  final GroupLeaderboardEntity leaderboard;

  const GroupSummaryCard({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              context,
              icon: Icons.sports_soccer_rounded,
              value: '${leaderboard.totalMatches}',
              label: 'مباراة ملعوبة',
              iconColor: isDark
                  ? AppColors.turfGreenNeon
                  : AppColors.turfGreenDark,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          Expanded(
            child: _buildMetricItem(
              context,
              icon: Icons.local_fire_department_rounded,
              value: '${leaderboard.totalGoals}',
              label: 'هدفاً مسجلاً',
              iconColor: AppColors.amberText,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          Expanded(
            child: _buildMetricItem(
              context,
              icon: Icons.trending_up_rounded,
              value: leaderboard.averageGoalsPerMatch.toStringAsFixed(1),
              label: 'معدل أهداف',
              iconColor: AppColors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

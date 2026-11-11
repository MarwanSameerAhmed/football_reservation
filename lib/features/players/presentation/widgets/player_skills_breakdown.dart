import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/player_entity.dart';

class PlayerSkillsBreakdown extends StatelessWidget {
  final PlayerEntity player;

  const PlayerSkillsBreakdown({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final skills = player.skills;

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'التقييم الفني الشامل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.meadowTintDark
                      : AppColors.meadowTint,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusCircular,
                  ),
                ),
                child: Text(
                  '${skills.overallScore} / 100',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppColors.turfGreenNeon
                        : AppColors.turfGreenDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(context, 'السرعة والانطلاق (PAC)', skills.pace),
          const SizedBox(height: 12),
          _buildStatRow(context, 'دقة وقوة التسديد (SHO)', skills.shooting),
          const SizedBox(height: 12),
          _buildStatRow(context, 'التمرير وصناعة اللعب (PAS)', skills.passing),
          const SizedBox(height: 12),
          _buildStatRow(
            context,
            'الدفاع وافتكاك الكرة (DEF)',
            skills.defending,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            context,
            'اللياقة والقوة البدنية (PHY)',
            skills.physical,
          ),
          if (player.primaryPosition == PlayerPosition.goalkeeper) ...[
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'مهارات الحراسة والتصدي (GK)',
              skills.goalkeeping,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int value) {
    final isDark = context.isDarkMode;

    Color progressColor;
    if (value >= 85) {
      progressColor =
          isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
    } else if (value >= 70) {
      progressColor =
          isDark ? AppColors.turfGreenNeon : AppColors.blueAccent;
    } else if (value >= 60) {
      progressColor = AppColors.amberText;
    } else {
      progressColor = AppColors.redText;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$value',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100.0,
            minHeight: 7.0,
            backgroundColor: isDark
                ? AppColors.surfaceDarkElevated
                : AppColors.canvasLight,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

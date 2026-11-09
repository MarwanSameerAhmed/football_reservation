import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../domain/entities/match_result_entity.dart';

class MatchResultCard extends StatelessWidget {
  final MatchResultEntity result;

  const MatchResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Status badge & Match Lock indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النتيجة الرسمية للمباراة',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              KickoffBadge(
                label: result.isLocked ? 'معتمدة ومغلقة 🔒' : 'مسودة النتيجة',
                variant: result.isLocked
                    ? BadgeVariant.success
                    : BadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scoreboard Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDarkElevated
                  : AppColors.canvasLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Team A
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.turfGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.teamAName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Score Numbers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${result.teamAScore}',
                        style: context.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.darkSlate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          ':',
                          style: context.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Text(
                        '${result.teamBScore}',
                        style: context.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.darkSlate,
                        ),
                      ),
                    ],
                  ),
                ),

                // Team B
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.textSecondaryLight
                              : AppColors.darkSlate,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.teamBName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Man of the Match (MOTM) Capsule
          if (result.manOfTheMatchName != null &&
              result.manOfTheMatchName!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amberTint.withValues(
                  alpha: isDark ? 0.2 : 0.6,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.amberText.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.military_tech_rounded,
                    color: AppColors.amberText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'رجل المباراة (MOTM):',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.amberText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      result.manOfTheMatchName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Goal Events Timeline
          if (result.goals.isNotEmpty) ...[
            Text(
              'سجل الأهداف (${result.totalGoals}) ⚽',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final goal = result.goals[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.canvasLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        goal.minute != null ? '${goal.minute}\'' : '⚽',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${goal.scorerName} (${goal.teamName})'
                        '${goal.assistPlayerName != null ? ' • صناعة ${goal.assistPlayerName}' : ''}'
                        '${goal.isPenalty ? ' (ركلة جزاء)' : ''}'
                        '${goal.isOwnGoal ? ' (هدف في مرماه)' : ''}',
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          // Cards Section
          if (result.cards.isNotEmpty) ...[
            Text(
              'البطاقات والإنذارات 🟨🟥',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: result.cards.map((card) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: card.isRedCard
                        ? AppColors.redTint
                        : AppColors.amberTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 12,
                        decoration: BoxDecoration(
                          color: card.isRedCard
                              ? AppColors.redText
                              : AppColors.amberText,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${card.playerName}${card.minute != null ? ' (${card.minute}\')' : ''}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: card.isRedCard
                              ? AppColors.redText
                              : AppColors.amberText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

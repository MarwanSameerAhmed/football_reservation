import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../domain/entities/generated_team_entity.dart';

class BalanceIndicatorBar extends StatelessWidget {
  final List<GeneratedTeamEntity>? teams;
  final double? scoreA;
  final double? scoreB;
  final String teamAName;
  final String teamBName;

  const BalanceIndicatorBar({
    super.key,
    this.teams,
    this.scoreA,
    this.scoreB,
    this.teamAName = 'الفريق الأول',
    this.teamBName = 'الفريق الثاني',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> teamNames;
    final List<double> teamScores;
    final List<Color> teamColors;

    if (teams != null && teams!.isNotEmpty) {
      teamNames = teams!.map((t) => t.name).toList();
      teamScores = teams!.map((t) => t.totalScore.toDouble()).toList();
      teamColors = [
        isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald,
        isDark ? Colors.lightBlueAccent : AppColors.blueAccent,
        AppColors.indigoAccent,
        AppColors.amberText,
      ];
    } else {
      final sA = scoreA ?? 0.0;
      final sB = scoreB ?? 0.0;
      teamNames = [teamAName, teamBName];
      teamScores = [sA, sB];
      teamColors = [
        AppColors.turfGreen,
        isDark ? AppColors.textSecondaryLight : AppColors.darkSlate,
      ];
    }

    final total = teamScores.fold(0.0, (sum, s) => sum + s);
    final avg = teamScores.isEmpty ? 0.0 : total / teamScores.length;
    final maxScore = teamScores.isEmpty ? 0.0 : teamScores.reduce(max);
    final minScore = teamScores.isEmpty ? 0.0 : teamScores.reduce(min);
    final diff = maxScore - minScore;
    final pctDiff = avg == 0.0 ? 0.0 : (diff / avg) * 100;

    final BadgeVariant badgeVariant;
    final String qualityText;
    if (pctDiff <= 3.0) {
      badgeVariant = BadgeVariant.success;
      qualityText = 'توازن استثنائي (${pctDiff.toStringAsFixed(1)}%)';
    } else if (pctDiff <= 7.0) {
      badgeVariant = BadgeVariant.success;
      qualityText = 'توازن ممتاز (${pctDiff.toStringAsFixed(1)}%)';
    } else if (pctDiff <= 12.0) {
      badgeVariant = BadgeVariant.warning;
      qualityText = 'توازن مقبول (${pctDiff.toStringAsFixed(1)}%)';
    } else {
      badgeVariant = BadgeVariant.danger;
      qualityText = 'فارق ملحوظ (${pctDiff.toStringAsFixed(1)}%)';
    }

    return KickoffCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مؤشر التكافؤ التكتيكي',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              KickoffBadge(label: qualityText, variant: badgeVariant),
            ],
          ),
          const SizedBox(height: 12),

          // Scores comparison
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: List.generate(teamScores.length, (index) {
              final color = teamColors[index % teamColors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${teamNames[index]} (${teamScores[index].toStringAsFixed(0)})',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),

          // Segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: List.generate(teamScores.length, (index) {
                  final s = teamScores[index];
                  final ratio = total == 0 ? 1 / teamScores.length : s / total;
                  final flex = (ratio * 1000).toInt().clamp(1, 1000);
                  final color = teamColors[index % teamColors.length];

                  return Expanded(
                    flex: flex,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index < teamScores.length - 1 ? 2.0 : 0.0,
                      ),
                      color: color,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

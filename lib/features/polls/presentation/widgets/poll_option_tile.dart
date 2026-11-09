import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/poll_option_entity.dart';

class PollOptionTile extends StatelessWidget {
  final PollOptionEntity option;
  final double percentage;
  final bool isSelectedByMe;
  final bool isWinner;
  final bool isClosed;
  final VoidCallback? onTap;

  const PollOptionTile({
    super.key,
    required this.option,
    required this.percentage,
    this.isSelectedByMe = false,
    this.isWinner = false,
    this.isClosed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final borderColor = isWinner
        ? AppColors.amberText
        : (isSelectedByMe
              ? AppColors.turfGreen
              : (isDark ? AppColors.borderDark : AppColors.borderLight));

    return InkWell(
      onTap: isClosed ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: (isWinner || isSelectedByMe) ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Percentage progress fill from the start
            Positioned.fill(
              child: Align(
                alignment: context.isRtl
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (percentage / 100.0).clamp(0.0, 1.0),
                  child: Container(
                    color: isWinner
                        ? AppColors.amberTint.withValues(
                            alpha: isDark ? 0.25 : 0.45,
                          )
                        : (isSelectedByMe
                              ? AppColors.meadowTint.withValues(
                                  alpha: isDark ? 0.25 : 0.5,
                                )
                              : (isDark
                                    ? AppColors.surfaceDarkElevated.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppColors.canvasLight.withValues(
                                        alpha: 0.6,
                                      ))),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Radio / Winner indicator
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isWinner
                          ? AppColors.amberText
                          : (isSelectedByMe
                                ? AppColors.turfGreen
                                : Colors.transparent),
                      border: Border.all(
                        color: isWinner
                            ? AppColors.amberText
                            : (isSelectedByMe
                                  ? AppColors.turfGreen
                                  : (isDark
                                        ? AppColors.textSecondaryLight
                                        : AppColors.borderLight)),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isWinner
                          ? const Icon(
                              Icons.emoji_events_rounded,
                              size: 15,
                              color: Colors.white,
                            )
                          : (isSelectedByMe
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppColors.darkSlate,
                                  )
                                : null),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Option texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.text,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: (isWinner || isSelectedByMe)
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isWinner) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.amberTint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'الفائز 🏆',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: AppColors.amberText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (option.subtitle != null &&
                            option.subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            option.subtitle!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryLight
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Vote Stats (Count & Percentage)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWinner
                              ? AppColors.amberText
                              : (isSelectedByMe
                                    ? (isDark
                                          ? AppColors.turfGreenNeon
                                          : AppColors.turfGreenDark)
                                    : null),
                        ),
                      ),
                      Text(
                        '${option.voteCount} أصوات',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textSecondaryLight
                              : AppColors.textHintLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

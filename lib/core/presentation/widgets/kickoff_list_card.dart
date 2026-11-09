import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';
import 'kickoff_badge.dart';

/// Horizontal List Card matching the "Court Vibe Check" items in screen 2.
class KickoffListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final BadgeVariant badgeVariant;
  final String? extraInfo;
  final Widget? leading;
  final VoidCallback? onTap;

  const KickoffListCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.badgeVariant = BadgeVariant.success,
    this.extraInfo,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Leading square thumbnail or player avatar
                leading ??
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.canvasLight,
                        child: Icon(
                          Icons.sports_soccer_rounded,
                          color: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.turfGreenDark,
                          size: 26,
                        ),
                      ),
                    ),

                const SizedBox(width: 12),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Badges and extra info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badgeLabel != null)
                      KickoffBadge(label: badgeLabel!, variant: badgeVariant),
                    if (extraInfo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        extraInfo!,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

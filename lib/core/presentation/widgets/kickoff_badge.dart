import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';

enum BadgeVariant {
  success, // Emerald (Confirmed, Available, Completed)
  warning, // Amber (Waitlist, Pending, MOTM)
  danger, // Crimson (Full, Cancelled, Penalty)
  neutral, // Muted slate (Draft, General Info)
  info, // Royal Blue (Polls, Scheduled, Announcements)
  tactical, // Indigo (Team Generator, Analytics)
}

/// Executive Status Pill with translucent semantic background and crisp `1px` border.
class KickoffBadge extends StatelessWidget {
  final String label;
  final Widget? leading;
  final BadgeVariant variant;
  final Color? customBackground;
  final Color? customTextColor;

  const KickoffBadge({
    super.key,
    required this.label,
    this.leading,
    this.variant = BadgeVariant.success,
    this.customBackground,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final Color accent;
    final Color? explicitBg;

    switch (variant) {
      case BadgeVariant.success:
        accent = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
        explicitBg = isDark ? null : AppColors.meadowTint;
        break;
      case BadgeVariant.warning:
        accent = isDark ? AppColors.amberNeon : AppColors.amberText;
        explicitBg = isDark ? null : AppColors.amberTint;
        break;
      case BadgeVariant.danger:
        accent = isDark ? AppColors.redNeon : AppColors.redText;
        explicitBg = isDark ? null : AppColors.redTint;
        break;
      case BadgeVariant.info:
        accent = isDark ? AppColors.blueNeon : AppColors.blueAccent;
        explicitBg = null;
        break;
      case BadgeVariant.tactical:
        accent = isDark ? AppColors.indigoNeon : AppColors.indigoAccent;
        explicitBg = null;
        break;
      case BadgeVariant.neutral:
        accent = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        explicitBg = isDark
            ? AppColors.surfaceDarkElevated
            : AppColors.surfaceElevatedLight;
        break;
    }

    final bg =
        customBackground ??
        explicitBg ??
        accent.withValues(alpha: isDark ? 0.16 : 0.11);
    final borderColor = customTextColor != null
        ? customTextColor!.withValues(alpha: 0.25)
        : (variant == BadgeVariant.neutral
              ? context.colorScheme.outlineVariant
              : accent.withValues(alpha: isDark ? 0.30 : 0.22));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          Flexible(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: customTextColor ?? accent,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

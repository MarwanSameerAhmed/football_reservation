import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

enum BadgeVariant {
  success, // Turf green (Safe, Confirmed, Available, Quiet)
  warning, // Amber (Moderate, Pending, Waiting List, Outdoor)
  danger, // Crimson (Squad Full, Expired, Penalty)
  neutral, // Muted slate (Draft, General Info)
}

/// Status and category badge pill strictly matching the reference design.
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

    Color bg;
    Color text;

    switch (variant) {
      case BadgeVariant.success:
        bg = isDark ? AppColors.meadowTintDark : AppColors.meadowTint;
        text = isDark ? AppColors.turfGreenNeon : AppColors.turfGreenDark;
        break;
      case BadgeVariant.warning:
        bg = isDark ? const Color(0xFF332514) : AppColors.amberTint;
        text = isDark ? const Color(0xFFFBBF24) : AppColors.amberText;
        break;
      case BadgeVariant.danger:
        bg = isDark ? const Color(0xFF3B1818) : AppColors.redTint;
        text = isDark ? const Color(0xFFF87171) : AppColors.redText;
        break;
      case BadgeVariant.neutral:
        bg = isDark ? AppColors.surfaceDarkElevated : AppColors.canvasLight;
        text = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: customBackground ?? bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: customTextColor ?? text,
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

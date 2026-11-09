import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

/// Interactive Choice Chip matching the Slots, Dates, Times, and Player counts
/// from the reference design.
class KickoffChoiceChip extends StatelessWidget {
  final String label;
  final String? subLabel;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const KickoffChoiceChip({
    super.key,
    required this.label,
    this.subLabel,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final selectedBg = isDark ? AppColors.meadowTintDark : AppColors.meadowTint;
    final unselectedBg = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    final selectedBorder = isDark
        ? AppColors.turfGreenNeon
        : AppColors.turfGreen;
    final unselectedBorder = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    final selectedTextColor = isDark
        ? AppColors.turfGreenNeon
        : AppColors.turfGreenDark;
    final unselectedTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '$label ${subLabel ?? ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: AnimatedContainer(
            duration: AppConstants.quickAnimation,
            constraints: BoxConstraints(
              minHeight: height ?? 44.0,
              minWidth: width ?? 0.0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: (subLabel != null) ? 6.0 : 8.0,
            ),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : unselectedBg,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: isSelected ? selectedBorder : unselectedBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? selectedTextColor
                            : context.theme.iconTheme.color,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? selectedTextColor
                            : unselectedTextColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (subLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subLabel!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? selectedTextColor.withValues(alpha: 0.8)
                          : AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

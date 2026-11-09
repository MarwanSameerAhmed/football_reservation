import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';
import 'kickoff_circle_button.dart';

/// Search field matching the exact capsule search bar and filter button
/// from the reference design.
class KickoffSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String? hintText;
  final bool showFilterButton;

  const KickoffSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hintText,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? context.l10n.searchPlaceholder;
    final isDark = context.isDarkMode;

    return Row(
      children: [
        // Pill Search Bar
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textHintLight,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: effectiveHint,
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHintLight,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Green Circular Filter Button (from reference design)
        if (showFilterButton && onFilterTap != null) ...[
          const SizedBox(width: 10),
          KickoffCircleButton(
            icon: Icons.tune_rounded,
            onPressed: onFilterTap!,
            size: 48,
            backgroundColor: isDark
                ? AppColors.turfGreenNeon
                : AppColors.turfGreen,
            iconColor: isDark ? AppColors.darkSlate : Colors.white,
            hasBorder: false,
            tooltip: 'تصفية',
          ),
        ],
      ],
    );
  }
}

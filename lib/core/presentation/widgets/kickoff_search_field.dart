import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
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
    this.showFilterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? context.l10n.searchPlaceholder;
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;

    return Row(
      children: [
        // Squircle Search Bar matching `tam_app` inputDecorationTheme (14px radius)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInput : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: effectiveHint,
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkMuted
                            : const Color(0xFF4B5563),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
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

        // Primary Royal Blue Filter Button
        if (showFilterButton && onFilterTap != null) ...[
          const SizedBox(width: 10),
          KickoffCircleButton(
            icon: Icons.tune_rounded,
            onPressed: onFilterTap!,
            size: 48,
            backgroundColor: cs.primary,
            iconColor: cs.onPrimary,
            hasBorder: false,
            tooltip: 'تصفية',
          ),
        ],
      ],
    );
  }
}

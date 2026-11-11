import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';

/// Executive Choice Chip with translucent emerald active fill & crisp hairline border.
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
    final cs = context.colorScheme;
    final accent = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;

    final selectedBg = accent.withValues(alpha: isDark ? 0.16 : 0.11);
    final unselectedBg = cs.surface;

    final selectedBorder = accent;
    final unselectedBorder = cs.outlineVariant;

    final selectedTextColor = isDark
        ? AppColors.turfGreenNeon
        : AppColors.turfGreenDark;
    final unselectedTextColor = cs.onSurface;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '$label ${subLabel ?? ''}',
      child: KickoffPressable(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.0),
            child: AnimatedContainer(
              duration: KickoffMotion.accessible(
                context,
                KickoffMotion.stateChange,
              ),
              curve: KickoffMotion.enter,
              constraints: BoxConstraints(
                minHeight: height ?? 44.0,
                minWidth: width ?? 0.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 13.0,
                vertical: (subLabel != null) ? 6.0 : 8.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : unselectedBg,
                borderRadius: BorderRadius.circular(14.0),
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
                              : cs.onSurfaceVariant,
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
                            ? selectedTextColor.withValues(alpha: 0.85)
                            : cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

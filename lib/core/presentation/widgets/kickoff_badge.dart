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
    final cs = context.colorScheme;

    final Color bg;
    final Color fg;

    switch (variant) {
      case BadgeVariant.success:
        bg = AppColors.emerald.withValues(alpha: isDark ? 0.16 : 0.11);
        fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF087F5B);
        break;
      case BadgeVariant.warning:
        bg = AppColors.amber.withValues(alpha: isDark ? 0.16 : 0.11);
        fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFF8A5500);
        break;
      case BadgeVariant.danger:
        bg = cs.errorContainer;
        fg = cs.onErrorContainer;
        break;
      case BadgeVariant.info:
      case BadgeVariant.tactical:
        bg = cs.primaryContainer;
        fg = cs.onPrimaryContainer;
        break;
      case BadgeVariant.neutral:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurfaceVariant;
        break;
    }

    final effectiveBg = customBackground ?? bg;
    final effectiveFg = customTextColor ?? fg;
    final borderColor = variant == BadgeVariant.neutral && customTextColor == null
        ? cs.outlineVariant
        : effectiveFg.withValues(alpha: 0.22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: effectiveBg,
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
                color: effectiveFg,
                fontWeight: FontWeight.w700,
                height: 1.2,
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

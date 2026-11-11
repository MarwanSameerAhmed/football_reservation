import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';

/// Executive Elevated Circular Icon Button matching header action & navigation controls.
class KickoffCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  final bool hasBorder;

  const KickoffCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44.0,
    this.tooltip,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final defaultBg = cs.surface;
    final defaultIconColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.darkSlate;

    return Semantics(
      button: true,
      label: tooltip ?? 'Circle Action',
      child: KickoffPressable(
        child: Tooltip(
          message: tooltip ?? '',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor ?? defaultBg,
                  border: hasBorder
                      ? Border.all(
                          color: cs.outlineVariant,
                          width: 1.0,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: size * 0.48,
                    color: iconColor ?? defaultIconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

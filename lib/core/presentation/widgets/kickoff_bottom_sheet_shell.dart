import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';

/// Standard, production-grade bottom sheet shell matching top-tier mobile apps.
///
/// Ensures:
/// 1. Ideal, constrained viewport height (e.g. 85% of screen height), leaving the backdrop dimmed at the top.
/// 2. Centered drag handle pill.
/// 3. Fixed header that never scrolls away (Title, Subtitle, and Close 'X' button).
/// 4. Smooth scrollable content viewport (`SingleChildScrollView` with bouncing physics).
/// 5. Pinned bottom action bar that is ALWAYS 100% visible, safe from keyboard and nav bars.
class KickoffBottomSheetShell extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? customHeader;
  final Widget child;
  final Widget? bottomAction;
  final double heightFactor;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onClose;

  const KickoffBottomSheetShell({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.customHeader,
    required this.child,
    this.bottomAction,
    this.heightFactor = 0.85,
    this.contentPadding,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final accent = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;

    final targetHeight = screenHeight * heightFactor;

    return Container(
      height: targetHeight,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.90,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Top Drag Handle (centered 44x4 pill)
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Fixed Header Row
          if (customHeader != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: customHeader!,
            )
          else if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.16 : 0.11),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                    tooltip: 'إغلاق',
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // Divider under fixed header
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant,
          ),

          // 3. Scrollable Content Viewport
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: child,
            ),
          ),

          // 4. Pinned Bottom Action Container
          if (bottomAction != null)
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: bottomInset > 0
                    ? bottomInset + 12
                    : (bottomPadding > 0 ? bottomPadding + 10 : 16),
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant,
                    width: 1.0,
                  ),
                ),
              ),
              child: bottomAction!,
            ),
        ],
      ),
    );
  }
}


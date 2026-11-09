import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

/// Standard container card matching the reference design.
///
/// Features smooth `24px` rounded corners, zero harsh shadows,
/// and consistent theming across light and dark modes.
class KickoffCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final double borderRadius;
  final double? width;
  final double? height;

  const KickoffCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius = AppConstants.radiusLarge,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg =
        backgroundColor ??
        context.theme.cardTheme.color ??
        context.colorScheme.surface;
    final effectivePadding =
        padding ??
        EdgeInsets.all(context.responsive(standard: 18.0, compact: 14.0));

    final cardContent = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.5),
              width: 1,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

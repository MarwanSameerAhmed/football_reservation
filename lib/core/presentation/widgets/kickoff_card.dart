import 'package:flutter/material.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';

/// Clean `tam_app` SectionCard container adhering to flat hairline borders.
///
/// Features crisp `1px` `outlineVariant` hairline borders, `18px` default
/// squircle corners, zero elevation, and tactile micro-scale when tappable.
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
    this.borderRadius = 18.0,
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
            Border.all(color: context.colorScheme.outlineVariant, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return KickoffPressable(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}

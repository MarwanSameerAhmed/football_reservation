import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

/// The Signature Action Button from the reference design.
///
/// Features a wide dark slate capsule, bold white typography,
/// and a prominent vivid turf-green trailing circular arrow button.
/// Automatically handles RTL directionality and loading states.
class KickoffActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? customIcon;
  final double? height;
  final Color? backgroundColor;
  final Color? circleColor;

  const KickoffActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.customIcon,
    this.height,
    this.backgroundColor,
    this.circleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;
    final defaultBg = context.isDarkMode
        ? AppColors.surfaceDarkElevated
        : AppColors.darkSlate;
    final effectiveBg = backgroundColor ?? defaultBg;

    final defaultCircle = context.isDarkMode
        ? AppColors.turfGreenNeon
        : AppColors.turfGreen;
    final effectiveCircle = circleColor ?? defaultCircle;

    final double effectiveHeight =
        height ??
        context.responsive<double>(standard: 56.0, compact: 50.0, tablet: 60.0);

    final double circleSize = effectiveHeight - 12.0;

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          child: AnimatedContainer(
            duration: AppConstants.quickAnimation,
            height: effectiveHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: onPressed == null
                  ? effectiveBg.withValues(alpha: 0.5)
                  : effectiveBg,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              boxShadow: [
                BoxShadow(
                  color: effectiveBg.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      label,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: context.responsive(
                          standard: 15.0,
                          compact: 13.5,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                ),

                // Signature Trailing Circle Button
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveCircle,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            customIcon ??
                                (isRtl
                                    ? Icons.chevron_left_rounded
                                    : Icons.chevron_right_rounded),
                            color: context.isDarkMode
                                ? Colors.black
                                : AppColors.darkSlate,
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

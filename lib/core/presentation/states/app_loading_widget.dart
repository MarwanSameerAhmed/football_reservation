import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';

/// Centralized, elegant loading indicator widget matching the Kickoff design system.
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoadingWidget({
    super.key,
    this.message,
    this.size = 36.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ??
        (context.isDarkMode
            ? AppColors.turfGreenNeon
            : AppColors.primaryEmerald);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3.2,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                backgroundColor: effectiveColor.withValues(alpha: 0.15),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

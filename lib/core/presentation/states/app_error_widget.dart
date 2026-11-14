import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

/// Reusable Error State Widget with retry support.
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? context.l10n.errorTitle;
    final effectiveMessage = message ?? context.l10n.errorDescription;
    final effectiveRetry = retryLabel ?? context.l10n.retry;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: context.verticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Squircle container with subtle crimson tint
            Builder(
              builder: (context) {
                final redAccent = context.isDarkMode
                    ? AppColors.redNeon
                    : AppColors.redText;
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: redAccent.withValues(
                      alpha: context.isDarkMode ? 0.16 : 0.10,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 38,
                    color: redAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                effectiveMessage,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(effectiveRetry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.isDarkMode
                      ? Colors.white
                      : AppColors.darkSlate,
                  side: BorderSide(
                    color: context.isDarkMode
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

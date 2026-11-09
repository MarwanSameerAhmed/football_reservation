import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';

/// Reusable Offline / No-Connection State Widget.
class AppOfflineWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const AppOfflineWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.isDarkMode
                    ? AppColors.surfaceDarkElevated
                    : AppColors.canvasLight,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: context.isDarkMode
                    ? Colors.white70
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.offlineMessage,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.errorDescription,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

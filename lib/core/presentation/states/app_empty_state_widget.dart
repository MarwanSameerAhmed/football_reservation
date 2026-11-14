import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

/// Reusable Empty State Widget following the Kickoff design tokens.
class AppEmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.sports_soccer_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? context.l10n.emptyTitle;
    final effectiveMessage = message ?? context.l10n.emptyDescription;

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
            // Squircle icon container with soft Emerald tint
            Builder(
              builder: (context) {
                final emerald = context.isDarkMode
                    ? AppColors.turfGreenNeon
                    : AppColors.primaryEmerald;
                return Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: emerald.withValues(
                      alpha: context.isDarkMode ? 0.16 : 0.10,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: emerald,
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
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
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

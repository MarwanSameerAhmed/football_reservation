import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Toast alert types supported by Kickoff.
enum KickoffToastType {
  success,
  error,
  warning,
  info,
}

/// Unified, aesthetic, floating pill toast matching the Kickoff design system.
class KickoffToast {
  KickoffToast._();

  /// Displays a floating pill toast message across the application.
  static void show(
    BuildContext context, {
    required String message,
    KickoffToastType type = KickoffToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        duration: duration,
        content: KickoffToastWidget(message: message, type: type),
      ),
    );
  }

  /// Convenience helper to show a success toast (lime green checkmark badge).
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: KickoffToastType.success,
      duration: duration,
    );
  }

  /// Convenience helper to show an error toast (vibrant red badge).
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: KickoffToastType.error,
      duration: duration,
    );
  }

  /// Convenience helper to show a warning toast (amber badge).
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: KickoffToastType.warning,
      duration: duration,
    );
  }

  /// Convenience helper to show an informational toast (sky/turf badge).
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: KickoffToastType.info,
      duration: duration,
    );
  }
}

/// Floating stadium pill container rendering the toast icon and text.
class KickoffToastWidget extends StatelessWidget {
  final String message;
  final KickoffToastType type;

  const KickoffToastWidget({
    super.key,
    required this.message,
    this.type = KickoffToastType.success,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final (accent, background, foreground, iconData) = switch (type) {
      KickoffToastType.success => (
          dark ? const Color(0xFF34D399) : AppColors.emerald,
          Color.alphaBlend(
            AppColors.emerald.withValues(alpha: dark ? 0.16 : 0.10),
            scheme.surface,
          ),
          scheme.onSurface,
          Icons.check_rounded,
        ),
      KickoffToastType.error => (
          scheme.error,
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.close_rounded,
        ),
      KickoffToastType.warning => (
          dark ? const Color(0xFFFBBF24) : AppColors.amber,
          Color.alphaBlend(
            AppColors.amber.withValues(alpha: dark ? 0.16 : 0.11),
            scheme.surface,
          ),
          scheme.onSurface,
          Icons.priority_high_rounded,
        ),
      KickoffToastType.info => (
          scheme.primary,
          Color.alphaBlend(
            scheme.primary.withValues(alpha: dark ? 0.14 : 0.08),
            scheme.surface,
          ),
          scheme.onSurface,
          Icons.info_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.22 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: dark ? 0.20 : 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Icon(
                iconData,
                size: 18,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


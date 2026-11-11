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
    final (badgeBg, iconColor, iconData) = switch (type) {
      KickoffToastType.success => (
          AppColors.turfGreenNeon,
          AppColors.canvasDark,
          Icons.check_rounded,
        ),
      KickoffToastType.error => (
          AppColors.redNeon,
          Colors.white,
          Icons.close_rounded,
        ),
      KickoffToastType.warning => (
          AppColors.amberNeon,
          AppColors.canvasDark,
          Icons.priority_high_rounded,
        ),
      KickoffToastType.info => (
          AppColors.blueNeon,
          AppColors.canvasDark,
          Icons.info_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSlate,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeBg.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Icon(
                iconData,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
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


import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../helpers/responsive_helper.dart';

/// Ensures mobile-first layout integrity on all screens.
/// On desktop or wide mobile-web viewports, it restricts width to [AppConstants.maxContentWidth]
/// and centers the content gracefully with subtle containment. On native mobile screens,
/// it natively fills the viewport.
class KickoffResponsiveShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;
  final bool enableSafePadding;

  const KickoffResponsiveShell({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.maxContentWidth,
    this.backgroundColor,
    this.enableSafePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedScaler = ResponsiveHelper.clampedTextScaler(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > maxWidth;

          Widget content = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          );

          if (isWideScreen) {
            // Elegant background framing for mobile web viewports
            return Container(
              color: theme.scaffoldBackgroundColor,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }
}

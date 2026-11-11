import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';
import '../../helpers/responsive_helper.dart';

/// Ensures mobile-first layout integrity on all screens.
///
/// Features:
/// 1. Status bar matching background canvas (#F6F7F5 / #0A0F0D) with dynamic icon brightness.
/// 2. Tap-anywhere to dismiss keyboard across the entire application.
/// 3. Clamped text scaling preventing UI overflow breaks.
/// 4. Graceful centering on wide desktop/web viewports.
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
    final isDark = theme.brightness == Brightness.dark;
    final clampedScaler = ResponsiveHelper.clampedTextScaler(context);
    final effectiveBgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: effectiveBgColor,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MediaQuery(
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
                return Container(
                  color: effectiveBgColor,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: effectiveBgColor,
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
        ),
      ),
    );
  }
}

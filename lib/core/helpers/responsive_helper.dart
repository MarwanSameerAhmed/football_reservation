import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Screen classification based on viewport width.
enum ScreenType {
  compact, // < 360px (e.g. iPhone SE, older/smaller devices)
  standard, // 360px - 480px (mainstream modern mobile phones)
  largeMobile, // 481px - 600px (foldables, large phablets)
  tablet, // > 600px (tablets, mobile web desktop viewers)
}

/// Helper class providing responsive calculations and breakpoints.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Determine the [ScreenType] for the given [BuildContext].
  static ScreenType getScreenType(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < AppConstants.compactScreenWidth) {
      return ScreenType.compact;
    } else if (width <= AppConstants.standardScreenWidth) {
      return ScreenType.standard;
    } else if (width <= 600.0) {
      return ScreenType.largeMobile;
    } else {
      return ScreenType.tablet;
    }
  }

  /// Select a value dynamically based on screen type.
  static T value<T>(
    BuildContext context, {
    required T standard,
    T? compact,
    T? largeMobile,
    T? tablet,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.compact:
        return compact ?? standard;
      case ScreenType.standard:
        return standard;
      case ScreenType.largeMobile:
        return largeMobile ?? standard;
      case ScreenType.tablet:
        return tablet ?? largeMobile ?? standard;
    }
  }

  /// Horizontal padding according to screen size.
  static double horizontalPadding(BuildContext context) {
    return value<double>(
      context,
      compact: 14.0,
      standard: 18.0,
      largeMobile: 22.0,
      tablet: 24.0,
    );
  }

  /// Vertical padding according to screen size.
  static double verticalPadding(BuildContext context) {
    return value<double>(
      context,
      compact: 12.0,
      standard: 16.0,
      largeMobile: 20.0,
      tablet: 24.0,
    );
  }

  /// Get clamped text scale factor to avoid UI overflows with large accessibility fonts.
  static TextScaler clampedTextScaler(
    BuildContext context, {
    double min = 0.85,
    double max = 1.25,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final scale = mediaQuery.textScaler.scale(1.0);
    final clamped = scale.clamp(min, max);
    return TextScaler.linear(clamped);
  }
}

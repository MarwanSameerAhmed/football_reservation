import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Typography System for Kickoff.
///
/// Designed to support Arabic (RTL) natively as the primary language
/// with clear hierarchy, comfortable line-heights, and responsive weights.
class AppTypography {
  AppTypography._();

  static const String primaryFontFamily = 'Tajawal';

  /// Builds a [TextTheme] for the application based on [colorScheme].
  static TextTheme createTextTheme({
    required Color textColor,
    required Color secondaryColor,
  }) {
    TextTheme baseTheme;
    try {
      baseTheme = GoogleFonts.tajawalTextTheme();
    } catch (_) {
      baseTheme = const TextTheme();
    }

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.25,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.25,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.35,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        height: 1.35,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
        height: 1.45,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
        height: 1.4,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.2,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),
    );
  }
}

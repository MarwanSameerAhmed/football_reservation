import 'package:flutter/material.dart';

/// Centralized Typography System for Kickoff / Formtor.
///
/// Configured with the official Thmanyah (خط ثمانية) font family from assets.
/// Features crisp w800 headings, clean hierarchy for Arabic RTL, and
/// tabular numeric helper styles (`tabularFigures`) for aligned counters.
class AppTypography {
  AppTypography._();

  static const String primaryFontFamily = 'Thmanyah';

  /// Helper list of font features for aligned scores, ratings, and timers.
  static const List<FontFeature> tabularFeatures = [
    FontFeature.tabularFigures(),
  ];

  /// Convenience modifier to apply aligned tabular figures to any [TextStyle].
  static TextStyle tabular(TextStyle? style) =>
      (style ?? const TextStyle(fontFamily: primaryFontFamily)).copyWith(
        fontFeatures: tabularFeatures,
      );

  /// Builds a [TextTheme] tuned for Executive Arabic & tabular clarity.
  static TextTheme createTextTheme({
    required Color textColor,
    required Color secondaryColor,
  }) {
    return TextTheme(
      displayLarge: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 34.0,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ).copyWith(color: textColor),
      displayMedium: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 28.0,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ).copyWith(color: textColor),
      titleLarge: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 22.0,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ).copyWith(color: textColor),
      titleMedium: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ).copyWith(color: textColor),
      titleSmall: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ).copyWith(color: secondaryColor),
      bodyLarge: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16.5,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ).copyWith(color: textColor),
      bodyMedium: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.normal,
        height: 1.45,
      ).copyWith(color: secondaryColor),
      bodySmall: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.normal,
        height: 1.4,
      ).copyWith(color: secondaryColor),
      labelLarge: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ).copyWith(color: textColor),
      labelMedium: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
      ).copyWith(color: secondaryColor),
      labelSmall: const TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
      ).copyWith(color: secondaryColor),
    );
  }
}

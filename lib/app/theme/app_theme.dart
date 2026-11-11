import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Central theme configuration for Kickoff / Formtor.
///
/// Implements the Executive Squircle M3 Surface Hierarchy:
/// - Full `ColorScheme` surface containers (`surface`, `surfaceContainerLow`, `inverseSurface`, etc.)
/// - Crisp `1px` `outlineVariant` hairline borders on cards & sheets (minimal elevation)
/// - Balanced Slate + Formtor Obsidian + Emerald + Owl Lime accents across Light & Dark modes.
class AppTheme {
  AppTheme._();

  /// Executive Light Theme — Clean Formtor Alabaster & Slate with Emerald + Owl Lime accents.
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(
      textColor: AppColors.textPrimaryLight,
      secondaryColor: AppColors.textSecondaryLight,
    );

    const colorScheme = ColorScheme.light(
      primary: AppColors.primaryEmerald,
      onPrimary: Colors.white,
      primaryContainer: AppColors.meadowTint,
      onPrimaryContainer: AppColors.turfGreenDark,
      secondary: AppColors.indigoAccent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEEF2FF),
      onSecondaryContainer: Color(0xFF3730A3),
      tertiary: AppColors.turfGreen,
      onTertiary: AppColors.darkSlate,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      surfaceContainerLowest: AppColors.surfaceLight,
      surfaceContainerLow: AppColors.surfaceContainerLowLight,
      surfaceContainer: AppColors.surfaceElevatedLight,
      surfaceContainerHigh: Color(0xFFE2E8F0),
      surfaceContainerHighest: Color(0xFFCBD5E1),
      inverseSurface: AppColors.darkSlate,
      onInverseSurface: Color(0xFFF8FAFC),
      outline: AppColors.textHintLight,
      outlineVariant: AppColors.borderLight,
      error: AppColors.redText,
      onError: Colors.white,
      errorContainer: AppColors.redTint,
      onErrorContainer: Color(0xFF991B1B),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.primaryFontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvasLight,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryLight,
          size: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedLight,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textHintLight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryEmerald,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.redText, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.redText, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkSlate,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  /// Executive Dark Theme — Deep Pitch Obsidian with Glowing Emerald & Formtor Lime accents.
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(
      textColor: AppColors.textPrimaryDark,
      secondaryColor: AppColors.textSecondaryDark,
    );

    const colorScheme = ColorScheme.dark(
      primary: AppColors.turfGreenNeon,
      onPrimary: AppColors.canvasDark,
      primaryContainer: AppColors.meadowTintDark,
      onPrimaryContainer: AppColors.turfGreenNeon,
      secondary: AppColors.indigoNeon,
      onSecondary: AppColors.canvasDark,
      secondaryContainer: Color(0xFF1E1B4B),
      onSecondaryContainer: AppColors.indigoNeon,
      tertiary: AppColors.owlLimeNeon,
      onTertiary: AppColors.canvasDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      surfaceContainerLowest: AppColors.canvasDark,
      surfaceContainerLow: Color(0xFF151E1A),
      surfaceContainer: AppColors.surfaceDarkElevated,
      surfaceContainerHigh: Color(0xFF212E28),
      surfaceContainerHighest: Color(0xFF2A3A33),
      inverseSurface: Color(0xFF0E1512),
      onInverseSurface: AppColors.textPrimaryDark,
      outline: AppColors.textHintDark,
      outlineVariant: AppColors.borderDark,
      error: AppColors.redNeon,
      onError: AppColors.canvasDark,
      errorContainer: Color(0xFF3F1518),
      onErrorContainer: AppColors.redNeon,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.primaryFontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvasDark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkElevated,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textHintDark,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.turfGreenNeon,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.redNeon, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.redNeon, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turfGreenNeon,
          foregroundColor: AppColors.canvasDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.turfGreenNeon,
          foregroundColor: AppColors.canvasDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

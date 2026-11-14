import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Central theme configuration faithfully matching the `tam_app` Design System:
/// - Clean Pure White canvas (`#FFFFFF`) & Slate-100 muted surfaces (`#F3F4F6`)
/// - Soft Graphite Dark theme (`#161A22` canvas, `#1D222C` surface, `#252B36` muted)
/// - Crisp `1px` `outlineVariant` borders (`#E5E7EB` / `#343C49`), zero heavy elevation
/// - Primary Electric Royal Blue (`#2563EB` light / `#6EA0FF` dark) + Deep Ink / White primary buttons
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(brightness: Brightness.light);
  static ThemeData get darkTheme => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final dark = brightness == Brightness.dark;
    const fontFamily = AppTypography.primaryFontFamily;

    final canvas = dark ? AppColors.darkCanvas : AppColors.canvas;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final surfaceMuted =
        dark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final input = dark ? AppColors.darkInput : AppColors.surface;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final text = dark ? AppColors.darkText : AppColors.ink;
    final muted = dark ? AppColors.darkMuted : AppColors.slate;
    final hintColor = dark ? AppColors.darkMuted : const Color(0xFF4B5563);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
      primary: dark ? AppColors.darkBlue : AppColors.blue,
      surface: surface,
      error: dark ? AppColors.darkRose : AppColors.rose,
    ).copyWith(
      onSurface: text,
      onSurfaceVariant: muted,
      primaryContainer:
          dark ? const Color(0xFF1E2D45) : AppColors.blueSoft,
      onPrimaryContainer:
          dark ? const Color(0xFFBFDBFE) : AppColors.blueHover,
      secondaryContainer:
          dark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
      onSecondaryContainer: text,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceMuted,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest:
          dark ? const Color(0xFF2D3442) : const Color(0xFFE5E7EB),
      inverseSurface: dark ? AppColors.darkSurfaceMuted : const Color(0xFF2E3036),
      onInverseSurface: const Color(0xFFF3F4F6),
      outline: border,
      outlineVariant: border,
    );

    final textTheme = AppTypography.createTextTheme(
      textColor: text,
      secondaryColor: muted,
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      hintColor: hintColor,
      fontFamily: fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: canvas,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: text, size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: TextStyle(
          color: hintColor,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: hintColor,
          fontFamily: fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: border.withValues(alpha: 0.65)),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 50)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return dark ? AppColors.darkBorder : AppColors.borderStrong;
            }
            return dark ? AppColors.darkText : AppColors.ink;
          }),
          foregroundColor: WidgetStatePropertyAll<Color>(
            dark ? AppColors.ink : Colors.white,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? AppColors.darkText : AppColors.ink,
          foregroundColor: dark ? AppColors.ink : Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 50)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(text),
          side: WidgetStatePropertyAll<BorderSide>(BorderSide(color: border)),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color>(text),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontFamily: fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color>(muted),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor:
            colorScheme.primary.withValues(alpha: dark ? 0.18 : 0.10),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: surfaceMuted,
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: TextStyle(
          color: text,
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.primary
              : surfaceMuted;
        }),
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return states.contains(WidgetState.selected) ? Colors.white : muted;
        }),
        trackOutlineColor: WidgetStatePropertyAll<Color>(border),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: dark ? AppColors.darkText : AppColors.ink,
        foregroundColor: dark ? AppColors.ink : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

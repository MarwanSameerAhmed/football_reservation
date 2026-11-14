import 'package:flutter/material.dart';

/// Centralized color palette copied from the `tam_app` design system:
/// - Crisp Pure White light canvas (`#FFFFFF`) & Slate-100 muted wells (`#F3F4F6`)
/// - Slate-200 hairline borders (`#E5E7EB`), Deep Ink headings (`#111827`), Electric Blue primary (`#2563EB`)
/// - Soft Graphite Dark Mode (`#161A22` canvas, `#1D222C` surface, `#252B36` muted, `#343C49` border, `#6EA0FF` primary)
/// - Restrained semantic tokens: Emerald (`#10B981`), Amber (`#F59E0B`), Rose (`#EF4444`)
abstract final class AppColors {
  // ── Authentic `tam_app` Tokens ────────────────────────────────────────────
  static const Color ink = Color(0xFF111827);
  static const Color slate = Color(0xFF6B7280);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueHover = Color(0xFF1D4ED8);
  static const Color blueSoft = Color(0xFFEEF4FF);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFEF4444);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFD1D5DB);

  // Soft Graphite Dark Theme (low glare without becoming pitch black)
  static const Color darkCanvas = Color(0xFF161A22);
  static const Color darkSurface = Color(0xFF1D222C);
  static const Color darkSurfaceMuted = Color(0xFF252B36);
  static const Color darkInput = Color(0xFF202630);
  static const Color darkBorder = Color(0xFF343C49);
  static const Color darkText = Color(0xFFF3F4F6);
  static const Color darkMuted = Color(0xFFB4BCC9);
  static const Color darkBlue = Color(0xFF6EA0FF);
  static const Color darkRose = Color(0xFFFF6B7D);

  // ── Unified Semantic Aliases mapped directly to `tam_app` ─────────────────
  static const Color canvasLight = canvas;
  static const Color surfaceLight = surface;
  static const Color surfaceContainerLowLight = surface;
  static const Color surfaceElevatedLight = surfaceMuted;
  static const Color borderLight = border;
  static const Color darkSlate = ink;

  static const Color primaryEmerald = blue;
  static const Color turfGreen = blue;
  static const Color turfGreenDark = blueHover;
  static const Color meadowTint = blueSoft;

  static const Color indigoAccent = blue;
  static const Color indigoNeon = darkBlue;
  static const Color blueAccent = blue;
  static const Color blueNeon = darkBlue;

  static const Color amberTint = Color(0xFFFEF3C7);
  static const Color amberText = Color(0xFFB45309);
  static const Color amberNeon = Color(0xFFFBBF24);

  static const Color redTint = Color(0xFFFEE2E2);
  static const Color redText = rose;
  static const Color redNeon = darkRose;

  static const Color textPrimaryLight = ink;
  static const Color textSecondaryLight = slate;
  static const Color textHintLight = slate;

  static const Color canvasDark = darkCanvas;
  static const Color surfaceDark = darkSurface;
  static const Color surfaceDarkElevated = darkSurfaceMuted;
  static const Color borderDark = darkBorder;

  static const Color turfGreenNeon = darkBlue;
  static const Color owlLimeNeon = emerald;
  static const Color meadowTintDark = Color(0xFF1E2A3D);

  static const Color textPrimaryDark = darkText;
  static const Color textSecondaryDark = darkMuted;
  static const Color textHintDark = darkMuted;
}

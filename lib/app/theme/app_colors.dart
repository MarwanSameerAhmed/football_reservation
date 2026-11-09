import 'package:flutter/material.dart';

/// Centralized color palette strictly derived from the reference design.
///
/// Features a warm organic canvas, vivid turf green accents, deep slate capsules,
/// and soft status badge tones.
abstract class AppColors {
  // ── Light Theme Palette ───────────────────────────────────────────────────
  /// Warm organic beige/cream canvas background
  static const Color canvasLight = Color(0xFFF5F2EB);

  /// Pure white surface for cards, dialogs, and inputs
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Subtle card border & divider
  static const Color borderLight = Color(0xFFEBE6DC);

  /// Deep slate/charcoal for signature pill buttons and dark surfaces
  static const Color darkSlate = Color(0xFF141917);

  /// Vivid turf/lime green accent (the circular icon button & active chips)
  static const Color turfGreen = Color(0xFF84CC16);

  /// Slightly deeper turf green for crisp text/borders on pastel backgrounds
  static const Color turfGreenDark = Color(0xFF4D7C0F);

  /// Soft pastel meadow green for selected chips and safe/quiet badges
  static const Color meadowTint = Color(0xFFEAF5DF);

  /// Warm amber/orange badge background (e.g. moderate, outdoor)
  static const Color amberTint = Color(0xFFFEF3C7);
  static const Color amberText = Color(0xFFD97706);

  /// Soft red/crimson badge background (e.g. absent, cancelled, penalty)
  static const Color redTint = Color(0xFFFEE2E2);
  static const Color redText = Color(0xFFDC2626);

  /// Primary text color (deep slate)
  static const Color textPrimaryLight = Color(0xFF141917);

  /// Secondary text color (muted charcoal gray)
  static const Color textSecondaryLight = Color(0xFF7E8480);

  /// Tertiary / Hint text color
  static const Color textHintLight = Color(0xFFA6ACA8);

  // ── Dark Theme Palette ────────────────────────────────────────────────────
  /// Deep obsidian dark canvas background
  static const Color canvasDark = Color(0xFF0E1311);

  /// Elevated dark card surface
  static const Color surfaceDark = Color(0xFF18201D);

  /// Secondary elevated surface (chips, inputs)
  static const Color surfaceDarkElevated = Color(0xFF222C28);

  /// Dark mode border color
  static const Color borderDark = Color(0xFF29352F);

  /// Neon turf green accent for dark mode high contrast
  static const Color turfGreenNeon = Color(0xFFA3E635);

  /// Meadow tint for dark mode
  static const Color meadowTintDark = Color(0xFF1F3323);

  /// Text colors in dark mode
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);
}

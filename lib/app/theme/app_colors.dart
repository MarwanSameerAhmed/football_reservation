import 'package:flutter/material.dart';

/// Centralized color palette unifying the Formtor Owl brand identity (`assets/`)
/// with the Executive Squircle M3 Surface Hierarchy (`tam_app`).
///
/// Light Mode: Clean Formtor Alabaster & Slate surfaces with Rich Pitch Emerald & Owl Lime accents.
/// Dark Mode: Deep Executive Obsidian Pitch surfaces with Neon Emerald & Electric Lime highlights.
abstract class AppColors {
  // ── Light Theme Palette ───────────────────────────────────────────────────
  /// Clean Formtor alabaster canvas background (matches logo & splash keyframe)
  static const Color canvasLight = Color(0xFFF6F7F5);

  /// Pure crisp white surface for cards, sheets, and dialogs
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Subtle low-elevation container well (list tiles, preview panels)
  static const Color surfaceContainerLowLight = Color(0xFFF8FAFC);

  /// Recessed Slate-100 track for segmented controls and subtle chips
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);

  /// Crisp hairline Slate-200 border & divider
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Deep Formtor Owl obsidian ink / charcoal for primary buttons & inverse hero
  static const Color darkSlate = Color(0xFF111815);

  /// Executive Emerald Green (high-contrast primary action & selected accent)
  static const Color primaryEmerald = Color(0xFF059669);

  /// Formtor Owl Electric Pitch Lime (signature accent glow & ring highlights)
  static const Color turfGreen = Color(0xFF76C709);

  /// Deep Emerald-700 for crisp legible text/icons on pastel meadow tints
  static const Color turfGreenDark = Color(0xFF047857);

  /// Crisp Emerald-50 soft pastel tint for active badges and selected tiles
  static const Color meadowTint = Color(0xFFECFDF5);

  /// Tactile / Analytics Indigo accent
  static const Color indigoAccent = Color(0xFF4F46E5);
  static const Color indigoNeon = Color(0xFF818CF8);

  /// Polls & Information Royal Blue accent
  static const Color blueAccent = Color(0xFF2563EB);
  static const Color blueNeon = Color(0xFF60A5FA);

  /// Warm Amber/Gold badge palette (Waitlist, MOTM, Outdoor alerts)
  static const Color amberTint = Color(0xFFFEF3C7);
  static const Color amberText = Color(0xFFD97706);
  static const Color amberNeon = Color(0xFFFBBF24);

  /// Soft Crimson badge palette (Withdrawals, Penalties, Cancellations)
  static const Color redTint = Color(0xFFFEE2E2);
  static const Color redText = Color(0xFFDC2626);
  static const Color redNeon = Color(0xFFF87171);

  /// Primary text color (Sharp Slate-900 ink)
  static const Color textPrimaryLight = Color(0xFF0F172A);

  /// Secondary text color (Slate-600 crisp subtitle)
  static const Color textSecondaryLight = Color(0xFF475569);

  /// Tertiary / Hint text color (Slate-400)
  static const Color textHintLight = Color(0xFF94A3B8);

  // ── Dark Theme Palette ────────────────────────────────────────────────────
  /// Deep Executive Obsidian Pitch canvas background
  static const Color canvasDark = Color(0xFF0A0F0D);

  /// Elevated dark card surface
  static const Color surfaceDark = Color(0xFF121916);

  /// Secondary elevated dark surface (chips, segmented tracks, inputs)
  static const Color surfaceDarkElevated = Color(0xFF1A2420);

  /// Dark mode crisp hairline border
  static const Color borderDark = Color(0xFF24322C);

  /// High-contrast glowing Emerald-400 accent for Dark Mode
  static const Color turfGreenNeon = Color(0xFF34D399);

  /// Formtor Owl Neon Lime highlight for Dark Mode badges & icons
  static const Color owlLimeNeon = Color(0xFFA3E635);

  /// Rich deep emerald tint for Dark Mode badges & containers
  static const Color meadowTintDark = Color(0xFF0E2920);

  /// Text colors in Dark Mode
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);
}

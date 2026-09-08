import 'package:flutter/material.dart';

/// Sheba Bondhu elevated brand palette.
///
/// Refined emerald green for trust, wealth, and wellness; warm amber for AI
/// insights and actions; high-contrast obsidian slate for typography.
class AppColors {
  AppColors._();

  // Primary Brand (Emerald & Forest)
  static const Color brandGreen = Color(0xFF0E7A53);
  static const Color brandGreenLight = Color(0xFFEBF6F1);
  static const Color brandGreenDark = Color(0xFF095237);
  static const Color brandGreenVibrant = Color(0xFF10B981);

  // Accent & AI (Warm Gold & Amber)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentSoft = Color(0xFFFEF3C7);
  static const Color accentDark = Color(0xFFB45309);

  // Severity
  static const Color critical = Color(0xFFEF4444);
  static const Color criticalSoft = Color(0xFFFEE2E2);
  static const Color important = Color(0xFFF97316);
  static const Color importantSoft = Color(0xFFFFEDD5);
  static const Color normal = Color(0xFF10B981);
  static const Color normalSoft = Color(0xFFECFDF5);

  // Neutrals (Slate Architecture)
  static const Color ink = Color(0xFF0F172A);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color white = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0E7A53), Color(0xFF084F35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF0E7A53), Color(0xFF10B981), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
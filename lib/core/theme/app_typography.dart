import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for Sheba Bondhu.
///
/// We use Hind Siliguri for Bangla and Inter for Latin script. Both have
/// excellent hinting at small sizes and feel warm/readable, matching our
/// "friendly helper" tone. Loaded lazily by google_fonts — no asset bundling.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(TextTheme base) {
    final bangla = GoogleFonts.hindSiliguriTextTheme(base);
    final inter = GoogleFonts.interTextTheme(base);

    return TextTheme(
      displayLarge: inter.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.ink,
      ),
      displayMedium: bangla.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: AppColors.ink,
      ),
      displaySmall: bangla.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineLarge: bangla.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineMedium: bangla.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineSmall: bangla.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleLarge: bangla.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: bangla.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleSmall: bangla.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: bangla.bodyLarge?.copyWith(
        color: AppColors.ink,
        height: 1.45,
      ),
      bodyMedium: bangla.bodyMedium?.copyWith(
        color: AppColors.ink,
        height: 1.4,
      ),
      bodySmall: bangla.bodySmall?.copyWith(
        color: AppColors.inkMuted,
        height: 1.35,
      ),
      labelLarge: bangla.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelMedium: bangla.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.inkMuted,
      ),
      labelSmall: bangla.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.inkMuted,
      ),
    );
  }
}
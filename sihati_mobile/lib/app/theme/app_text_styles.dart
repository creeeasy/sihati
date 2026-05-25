import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ═══════════════════════════════════════════════════════════════
  // Font Families
  // ═══════════════════════════════════════════════════════════════
  static const String _heading = 'Nunito';
  static const String _body = 'Inter';

  // ═══════════════════════════════════════════════════════════════
  // Display Styles (Large headings — Nunito)
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _heading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _heading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _heading,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: _heading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════
  // Heading aliases (h1–h6) for backward compatibility
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle h1 = TextStyle(
    fontFamily: _heading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _heading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _heading,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _heading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: _heading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: _heading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════
  // Title / Subtitle Styles (Inter)
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle title = TextStyle(
    fontFamily: _body,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// Alias kept for backward compatibility
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  /// Alias kept for backward compatibility
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════════
  // Body Styles (Inter)
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════════
  // Label Styles (Inter — buttons, tabs, chips)
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _body,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
  );

  // ═══════════════════════════════════════════════════════════════
  // Specialty Styles
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle input = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle helper = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textTertiary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: AppColors.white,
  );

  static const TextStyle link = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}

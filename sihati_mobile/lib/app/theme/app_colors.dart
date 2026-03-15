import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // Primary Brand Colors
  // ═══════════════════════════════════════════════════════════════

  // Primary - Medical Blue (Trust, Professional)
  static const Color primary = Color(0xFF2E7BF6); // Main blue
  static const Color primaryDark = Color(0xFF1E5BC6); // Darker blue
  static const Color primaryLight = Color(0xFF5B9BFF); // Lighter blue
  static const Color primarySoft =
      Color(0xFFE8F2FF); // Very light blue (backgrounds)

  // Secondary - Medical Teal (Health, Wellness)
  static const Color secondary = Color(0xFF00BFA5); // Teal
  static const Color secondaryDark = Color(0xFF00897B); // Dark teal
  static const Color secondaryLight = Color(0xFF64FFDA); // Light teal
  static const Color secondarySoft = Color(0xFFE0F7F4); // Very light teal

  // Accent - Warm Orange (Action, Energy)
  static const Color accent = Color(0xFFFF6B35); // Vibrant orange
  static const Color accentLight = Color(0xFFFF8A65); // Light orange
  static const Color accentSoft = Color(0xFFFFEDE8); // Very light orange

  // ═══════════════════════════════════════════════════════════════
  // Semantic Colors (Medical Context)
  // ═══════════════════════════════════════════════════════════════

  // Success - Green (Healthy, Confirmed)
  static const Color success = Color(0xFF10B981); // Fresh green
  static const Color successDark = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);

  // Warning - Amber (Caution, Attention)
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Error - Red (Danger, Critical)
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Info - Cyan (Information, Tips)
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════════
  // Neutral Colors (Grays)
  // ═══════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF1F2937); // Almost black
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray
  static const Color textDisabled = Color(0xFFD1D5DB); // Very light gray

  static const Color background = Color(0xFFF9FAFB); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color border = Color(0xFFE5E7EB); // Light gray
  static const Color divider = Color(0xFFF3F4F6); // Very light gray

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ═══════════════════════════════════════════════════════════════
  // Specialty-Specific Colors
  // ═══════════════════════════════════════════════════════════════

  static const Color cardiology = Color(0xFFE91E63); // Pink (heart)
  static const Color neurology = Color(0xFF9C27B0); // Purple (brain)
  static const Color pediatrics = Color(0xFF4CAF50); // Green (child)
  static const Color dermatology = Color(0xFFFF9800); // Orange (skin)
  static const Color orthopedics = Color(0xFF607D8B); // Blue-gray (bones)
  static const Color pharmacy = Color(0xFF00BCD4); // Cyan (medicine)

  // ═══════════════════════════════════════════════════════════════
  // Gradients
  // ═══════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7BF6), Color(0xFF1E5BC6)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
  );

  // Service card gradients
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient healthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
  );

  static const LinearGradient locationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  // ═══════════════════════════════════════════════════════════════
  // Shadows
  // ═══════════════════════════════════════════════════════════════

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.15),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}

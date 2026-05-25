import 'package:flutter/material.dart';

class AppSpacing {
  // Component sizes
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double iconSizeSm = 18;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 32;
  static const double avatarSizeSm = 36;
  static const double avatarSizeMd = 48;
  static const double avatarSizeLg = 72;
  // ═══════════════════════════════════════════════════════════════
  // Spacing Scale (4px base unit - follows Material Design)
  // ═══════════════════════════════════════════════════════════════
  // Base scale
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  // Screen insets
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets paddingCard = EdgeInsets.all(16);
  static const EdgeInsets paddingInput =
      EdgeInsets.symmetric(horizontal: 12, vertical: 16);

  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusFull = 999;

  // ═══════════════════════════════════════════════════════════════
  // Padding Presets
  // ═══════════════════════════════════════════════════════════════

  static BorderRadius get cardRadius => BorderRadius.circular(radiusLg);
  static BorderRadius get inputRadius => BorderRadius.circular(radiusMd);
  static BorderRadius get chipRadius => BorderRadius.circular(radiusFull);
  static BorderRadius get buttonRadius => BorderRadius.circular(radiusFull);
  // Horizontal only
  static const EdgeInsets paddingHorizontalXs =
      EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl =
      EdgeInsets.symmetric(horizontal: xl);

  // Vertical only
  static const EdgeInsets paddingVerticalXs =
      EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl =
      EdgeInsets.symmetric(vertical: xl);

  // ═══════════════════════════════════════════════════════════════
  // Component-Specific Padding
  // ═══════════════════════════════════════════════════════════════

  // Cards
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12);

  // Screens
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets screenPaddingVertical =
      EdgeInsets.symmetric(vertical: 16);

  // Buttons
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const EdgeInsets buttonPaddingLarge =
      EdgeInsets.symmetric(horizontal: 32, vertical: 16);
  static const EdgeInsets buttonPaddingSmall =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  // Input fields
  static const EdgeInsets inputPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  // List items
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}

class AppSizing {
  // ═══════════════════════════════════════════════════════════════
  // Border Radius
  // ═══════════════════════════════════════════════════════════════

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0; // Pill shape

  // BorderRadius objects
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ═══════════════════════════════════════════════════════════════
  // Icon Sizes
  // ═══════════════════════════════════════════════════════════════

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // ═══════════════════════════════════════════════════════════════
  // Button Heights
  // ═══════════════════════════════════════════════════════════════

  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightXl = 60.0;

  // ═══════════════════════════════════════════════════════════════
  // Avatar Sizes
  // ═══════════════════════════════════════════════════════════════

  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;
  static const double avatarXxl = 128.0;

  // ═══════════════════════════════════════════════════════════════
  // Touch Targets (Minimum for accessibility)
  // ═══════════════════════════════════════════════════════════════

  static const double minTouchTarget = 44.0; // iOS guideline
  static const double minTouchTargetAndroid = 48.0; // Material Design guideline

  // ═══════════════════════════════════════════════════════════════
  // Card Heights
  // ═══════════════════════════════════════════════════════════════

  static const double cardHeightSm = 80.0;
  static const double cardHeightMd = 120.0;
  static const double cardHeightLg = 200.0;

  // ═══════════════════════════════════════════════════════════════
  // Elevation (for shadows)
  // ═══════════════════════════════════════════════════════════════

  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
}

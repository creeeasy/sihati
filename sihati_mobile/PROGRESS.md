# Sihati Mobile — Design Enhancement Pass

You are an expert Flutter UI/UX designer. The Sihati mobile app has already undergone a first UI pass — all screens now use custom SVG icons, an expanded color palette, proper spacing, and a new typography system (Nunito + Inter). Your job is to make everything look **polished, premium, and delightful** — push the design from "clean" to "stunning."

**CRITICAL:** Only modify `build()` methods in screen and widget files, plus the theme files. Never touch providers, repositories, controllers, models, services, or bindings. All text must stay in French.

---

## 1. WHAT'S ALREADY DONE (DON'T RE-DO)

- Custom SVG icon system (`AppIcons` class, 48 icons)
- Full color palette (Primary scale 50-900, Neutrals 50-900, semantic colors, gradients, shadows)
- Typography system (Nunito for headings, Inter for body — 13 text styles)
- Spacing/layout system (`AppSpacing` with spacing scale, radius scale, component sizes)
- Basic screen layout improvements (spacing, card styling, chip design)

## 2. WHAT YOU'RE HERE TO DO

Elevate the existing design with professional polish:

### Visual Hierarchy & Layout

- Audit every screen for visual weight — headers should command attention, CTAs should be unmistakable, secondary info should recede
- Cards need breathing room. Add subtle dividers or negative space between sections
- Lists should have generous padding and clear item separation
- Use the expanded color palette aggressively — `primary700` for pressed states, `neutral50` for backgrounds, `primarySoftGradient` for feature cards

### Card Design

- Every card should have: `AppSpacing.cardRadius`, `AppColors.surfaceCard` background, `AppColors.shadowSm`, and `AppSpacing.paddingCard`
- Interactive cards need distinct hover/press states — elevate shadow on press, subtle scale animation
- Cards with status (pharmacy open/closed, appointment pending/confirmed) should use the left-border accent pattern consistently: `Border(left: BorderSide(color: statusColor, width: 4))`

### Buttons & CTAs

- Primary actions: full-width, `AppColors.primaryGradient`, `AppSpacing.buttonHeight` (52px), `AppSpacing.buttonRadius`, white text in `AppTextStyles.labelLarge`
- Secondary actions: outlined, `AppColors.primary` border, transparent background
- Destructive actions (cancel, delete, logout): text-only with `AppColors.error` color — no background, no card
- FABs: if used, must have `AppColors.shadowPrimary`, `AppSpacing.radiusFull`, icon in white

### Navigation & App Bars

- AppBars: transparent or gradient background, white icons, `AppTextStyles.displaySmall` for title
- Back buttons: `SvgPicture.asset(AppIcons.arrowBack)` in a semi-transparent white container, `AppSpacing.radiusSm`, size `AppSpacing.iconSizeMd`
- Tab bars: animated underline indicator, `AppColors.primary`, 3px thick, label-sized, with `AppTextStyles.labelMedium`

### Lists & Grids

- List items: 12-16px vertical padding, subtle bottom border or card separation
- Grid items (services, stats): equal height cards, centered content, `AppSpacing.cardRadius`
- Empty states: follow the template from the first pass — 80px icon in soft circle + friendly title + supportive subtitle

### Typography Refinement

- Headings must use `AppTextStyles.displayLarge/Medium/Small` (Nunito) — never body font for titles
- Body text must use `AppTextStyles.bodyLarge/Medium/Small` (Inter)
- Labels and buttons use `AppTextStyles.labelLarge/Medium`
- Never hard-code font sizes or families — always use the theme tokens

### Color Refinement

- Backgrounds: `AppColors.neutral50` or `AppColors.background`
- Cards: `AppColors.surfaceCard` (white)
- Text inputs: `AppColors.surfaceInput` with `AppColors.borderDefault` outline, `AppColors.primary` focus border
- Text: `AppColors.textPrimary` for headings, `AppColors.textSecondary` for body, `AppColors.textTertiary` for hints
- Never hard-code hex values — always use `AppColors.xxx`

### Micro-interactions (Enhance)

- All interactive elements must have a press state (scale 0.97 or shadow lift)
- Page transitions: natural slide or fade — use GetX's built-in transitions
- Pull-to-refresh: `AppColors.primary` indicator
- Toggle switches: `Switch.adaptive` with `AppColors.primary` active color
- Favorite toggle: scale animation on the heart icon

### Pharmacy-Specific Polish

- "De garde" chip: subtle pulse glow animation on the border
- Opening hours: today's row highlighted with `AppColors.primarySoft` background
- Map view: cards in the horizontal strip should have a subtle shadow lift on the selected/centered item

### Doctor-Specific Polish

- Doctor cards: larger avatar, specialty name as a soft pill under the name
- Rating stars: use `SvgPicture.asset(AppIcons.starFilled)` in `AppColors.warning` color
- Available slots: selected slot = filled primary pill, unselected = outlined

### Appointment-Specific Polish

- Timeline left border: 4px wide, color-coded by status
- Status badges: soft pill with 60% opacity background
- Cancel confirmation: friendly icon + clear French message

### Medical Record Polish

- Tabs: animated underline, `TabBarIndicatorSize.label`
- Stat cards: icon in colored circle, large count, small label
- Allergy chips: severity-colored left border (3px)
- Documents: file-type colored thumbnail instead of generic icon

### Profile Polish

- Header: dramatic gradient wave, tall (220px+), avatar overlapping the wave bottom
- Avatar: white ring border + primary shadow
- Settings rows: icon in colored circle, label + value, chevron right
- Logout: subtle red text button — not a card, not a filled button

---

## 3. SCREEN CHECKLIST

Go through EVERY screen and widget in this order:

1. Home
2. Pharmacy List
3. Pharmacy Detail
4. Duty Pharmacies
5. Doctor List
6. Doctor Detail
7. Book Appointment
8. My Appointments
9. Appointment Card (widget)
10. Medications List
11. Medication Detail
12. Medication Search
13. Medical Record (all 5 tabs)
14. AI Chat
15. AI History
16. Favorites
17. Profile
18. Login
19. Register
20. Splash
21. All shared widgets (custom_button, custom_text_field, loading_indicator, empty_state, error_widget, favorite_button, pharmacy_card, doctor_card, medication_result_card, pharmacy_stock_card, appointment_card)

For each screen, verify:

- [ ] Uses `AppTextStyles` (never hard-coded font sizes)
- [ ] Uses `AppColors` (never hard-coded hex values)
- [ ] Uses `AppSpacing` (never raw numbers for padding/margin/radius)
- [ ] Uses `SvgPicture.asset(AppIcons.xxx)` (never `Icon(Icons.xxx)`)
- [ ] Cards use left-border accent pattern for status
- [ ] Buttons follow the primary/secondary/destructive rules
- [ ] Empty/error states follow the template
- [ ] All text is in French
- [ ] Interactive elements have press feedback

---

## 4. CONSTRAINTS

- Do NOT modify: providers, repositories, controllers, models, services, bindings
- Do NOT change: navigation logic, route names
- ONLY modify: `build()` methods, theme files, shared widgets
- All text in French
- Preserve the blue brand identity
- The app must feel **premium, polished, warm, and trustworthy**

class AppIcons {
static const \_base = 'assets/icons';

// Navigation
static const String home = '$_base/home.svg';
  static const String search = '$\_base/search.svg';
static const String calendar = '$_base/calendar.svg';
  static const String profile = '$\_base/profile.svg';
static const String settings = '$_base/settings.svg';
  static const String arrowBack = '$\_base/arrow_back.svg';
static const String arrowForward = '$_base/arrow_forward.svg';
  static const String close = '$\_base/close.svg';
static const String menu = '$_base/menu.svg';
  static const String more = '$\_base/more.svg';

// Medical
static const String doctor = '$_base/doctor.svg';
  static const String pharmacy = '$\_base/pharmacy.svg';
static const String medication = '$_base/medication.svg';
  static const String hospital = '$\_base/hospital.svg';
static const String appointment = '$_base/appointment.svg';
  static const String prescription = '$\_base/prescription.svg';
static const String consultation = '$_base/consultation.svg';
  static const String medicalRecord = '$\_base/medical_record.svg';
static const String allergy = '$_base/allergy.svg';
  static const String stethoscope = '$\_base/stethoscope.svg';
static const String heart = '$_base/heart.svg';
  static const String emergency = '$\_base/emergency.svg';

// Actions
static const String favoriteOutlined = '$_base/favorite_outlined.svg';
  static const String favoriteFilled = '$\_base/favorite_filled.svg';
static const String share = '$_base/share.svg';
  static const String download = '$\_base/download.svg';
static const String upload = '$_base/upload.svg';
  static const String delete = '$\_base/delete.svg';
static const String edit = '$_base/edit.svg';
  static const String add = '$\_base/add.svg';
static const String phone = '$_base/phone.svg';
  static const String chat = '$\_base/chat.svg';
static const String directions = '$_base/directions.svg';
  static const String qrCode = '$\_base/qr_code.svg';
static const String notification = '$_base/notification.svg';
  static const String reminder = '$\_base/reminder.svg';

// Status
static const String verified = '$_base/verified.svg';
  static const String warning = '$\_base/warning.svg';
static const String errorIcon = '$_base/error.svg';
  static const String info = '$\_base/info.svg';
static const String lock = '$_base/lock.svg';
  static const String starOutlined = '$\_base/star_outlined.svg';
static const String starFilled = '$\_base/star_filled.svg';

// Misc
static const String moon = '$_base/moon.svg';
  static const String location = '$\_base/location.svg';
static const String filter = '$_base/filter.svg';
  static const String send = '$\_base/send.svg';
static const String history = '$_base/history.svg';
  static const String aiPsychology = '$\_base/ai_psychology.svg';
static const String logout = '$_base/logout.svg';
  static const String language = '$\_base/language.svg';
static const String privacy = '$_base/privacy.svg';
  static const String help = '$\_base/help.svg';
}
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

// ═══════════════════════════════════════════════════════════════
// Full Shade Scales (New)
// ═══════════════════════════════════════════════════════════════
// Primary blue shades
static const Color primary50 = Color(0xFFEBF2FF);
static const Color primary100 = Color(0xFFD6E6FF);
static const Color primary200 = Color(0xFFADCBFF);
static const Color primary300 = Color(0xFF85B0FF);
static const Color primary400 = Color(0xFF5B9BFF); // = existing primaryLight
static const Color primary500 = Color(0xFF2E7BF6); // = existing primary
static const Color primary600 = Color(0xFF1E5BC6); // = existing primaryDark
static const Color primary700 = Color(0xFF1544A0);
static const Color primary800 = Color(0xFF0E2E7A);
static const Color primary900 = Color(0xFF071854);
// Neutral grays
static const Color neutral50 = Color(0xFFF9FAFB);
static const Color neutral100 = Color(0xFFF3F4F6);
static const Color neutral200 = Color(0xFFE5E7EB);
static const Color neutral300 = Color(0xFFD1D5DB);
static const Color neutral400 = Color(0xFF9CA3AF);
static const Color neutral500 = Color(0xFF6B7280);
static const Color neutral600 = Color(0xFF4B5563);
static const Color neutral700 = Color(0xFF374151);
static const Color neutral800 = Color(0xFF1F2937);
static const Color neutral900 = Color(0xFF111827);
// Success shades
static const Color success50 = Color(0xFFECFDF5);
static const Color success100 = Color(0xFFD1FAE5);
static const Color success200 = Color(0xFFA7F3D0);
static const Color success500 = Color(0xFF10B981);
static const Color success700 = Color(0xFF047857);
// Warning shades
static const Color warning50 = Color(0xFFFFFBEB);
static const Color warning100 = Color(0xFFFEF3C7);
static const Color warning200 = Color(0xFFFDE68A);
static const Color warning500 = Color(0xFFF59E0B);
static const Color warning700 = Color(0xFFB45309);
// Error shades
static const Color error50 = Color(0xFFFEF2F2);
static const Color error100 = Color(0xFFFEE2E2);
static const Color error200 = Color(0xFFFECACA);
static const Color error500 = Color(0xFFEF4444);
static const Color error700 = Color(0xFFB91C1C);
// ═══════════════════════════════════════════════════════════════
// Semantic Surface Tokens
// ═══════════════════════════════════════════════════════════════
static const Color surfaceCard = Color(0xFFFFFFFF);
static const Color surfaceInput = Color(0xFFF3F6FF);
static const Color surfaceOverlay = Color(0xFFF0F5FF);
static const Color textOnPrimary = Color(0xFFFFFFFF);
static const Color borderLight = Color(0xFFEEF2FF);
static const Color borderDefault = Color(0xFFE5E7EB);
// ═══════════════════════════════════════════════════════════════
// Additional Shadows
// ═══════════════════════════════════════════════════════════════
static List<BoxShadow> get shadowXs => [
BoxShadow(
color: const Color(0xFF000000).withOpacity(0.03),
blurRadius: 2,
offset: const Offset(0, 1)),
];
static List<BoxShadow> get shadowPrimary => [
BoxShadow(
color: const Color(0xFF2E7BF6).withOpacity(0.25),
blurRadius: 12,
offset: const Offset(0, 4)),
];
// ═══════════════════════════════════════════════════════════════
// Additional Gradients
// ═══════════════════════════════════════════════════════════════
static const LinearGradient primarySoftGradient = LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [Color(0xFFEBF2FF), Color(0xFFD6E6FF)],
);
static const LinearGradient homeHeaderGradient = LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [Color(0xFF1544A0), Color(0xFF2E7BF6)],
);
static const LinearGradient profileWaveGradient = LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [Color(0xFF0E2E7A), Color(0xFF2E7BF6)],
);
}

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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
// ═══════════════════════════════════════════════════════════════
// Font Family
// ═══════════════════════════════════════════════════════════════

// Primary font: Inter (modern, clean, highly readable)
static String get \_fontFamily => GoogleFonts.poppins().fontFamily!;

// Alternative: Poppins (friendlier, rounder)
// static String get \_fontFamily => GoogleFonts.poppins().fontFamily!;

// ═══════════════════════════════════════════════════════════════
// Display Styles (Large headings)
// ═══════════════════════════════════════════════════════════════

static TextStyle displayLarge = TextStyle(
fontFamily: \_fontFamily,
fontSize: 32,
fontWeight: FontWeight.bold,
height: 1.2,
letterSpacing: -0.5,
color: AppColors.textPrimary,
);

static TextStyle displayMedium = TextStyle(
fontFamily: \_fontFamily,
fontSize: 28,
fontWeight: FontWeight.bold,
height: 1.25,
letterSpacing: -0.3,
color: AppColors.textPrimary,
);

static TextStyle displaySmall = TextStyle(
fontFamily: \_fontFamily,
fontSize: 24,
fontWeight: FontWeight.bold,
height: 1.3,
letterSpacing: 0,
color: AppColors.textPrimary,
);

// ═══════════════════════════════════════════════════════════════
// Heading Styles (h1-h6)
// ═══════════════════════════════════════════════════════════════

static TextStyle h1 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 32,
fontWeight: FontWeight.w700,
height: 1.25,
letterSpacing: -0.5,
color: AppColors.textPrimary,
);

static TextStyle h2 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 28,
fontWeight: FontWeight.w700,
height: 1.3,
letterSpacing: -0.3,
color: AppColors.textPrimary,
);

static TextStyle h3 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 24,
fontWeight: FontWeight.w600,
height: 1.35,
letterSpacing: 0,
color: AppColors.textPrimary,
);

static TextStyle h4 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 20,
fontWeight: FontWeight.w600,
height: 1.4,
letterSpacing: 0,
color: AppColors.textPrimary,
);

static TextStyle h5 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 18,
fontWeight: FontWeight.w600,
height: 1.4,
letterSpacing: 0,
color: AppColors.textPrimary,
);

static TextStyle h6 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 16,
fontWeight: FontWeight.w600,
height: 1.5,
letterSpacing: 0,
color: AppColors.textPrimary,
);

// ═══════════════════════════════════════════════════════════════
// Body Styles
// ═══════════════════════════════════════════════════════════════

static TextStyle bodyLarge = TextStyle(
fontFamily: \_fontFamily,
fontSize: 16,
fontWeight: FontWeight.w400,
height: 1.6,
letterSpacing: 0.15,
color: AppColors.textPrimary,
);

static TextStyle bodyMedium = TextStyle(
fontFamily: \_fontFamily,
fontSize: 14,
fontWeight: FontWeight.w400,
height: 1.6,
letterSpacing: 0.15,
color: AppColors.textPrimary,
);

static TextStyle bodySmall = TextStyle(
fontFamily: \_fontFamily,
fontSize: 12,
fontWeight: FontWeight.w400,
height: 1.5,
letterSpacing: 0.1,
color: AppColors.textSecondary,
);

// ═══════════════════════════════════════════════════════════════
// Label Styles (Buttons, tabs, chips)
// ═══════════════════════════════════════════════════════════════

static TextStyle labelLarge = TextStyle(
fontFamily: \_fontFamily,
fontSize: 15,
fontWeight: FontWeight.w600,
height: 1.3,
letterSpacing: 0.3,
color: AppColors.textPrimary,
);

static TextStyle labelMedium = TextStyle(
fontFamily: \_fontFamily,
fontSize: 13,
fontWeight: FontWeight.w600,
height: 1.3,
letterSpacing: 0.3,
color: AppColors.textPrimary,
);

static TextStyle labelSmall = TextStyle(
fontFamily: \_fontFamily,
fontSize: 11,
fontWeight: FontWeight.w600,
height: 1.2,
letterSpacing: 0.5,
color: AppColors.textSecondary,
);

// ═══════════════════════════════════════════════════════════════
// Specialty Styles
// ═══════════════════════════════════════════════════════════════

static TextStyle caption = TextStyle(
fontFamily: \_fontFamily,
fontSize: 12,
fontWeight: FontWeight.w400,
height: 1.4,
letterSpacing: 0.2,
color: AppColors.textSecondary,
);

static TextStyle overline = TextStyle(
fontFamily: \_fontFamily,
fontSize: 11,
fontWeight: FontWeight.w600,
height: 1.3,
letterSpacing: 1.0,
color: AppColors.textSecondary,
);

static TextStyle button = TextStyle(
fontFamily: \_fontFamily,
fontSize: 15,
fontWeight: FontWeight.w600,
height: 1.2,
letterSpacing: 0.5,
color: AppColors.white,
);

static TextStyle link = TextStyle(
fontFamily: \_fontFamily,
fontSize: 14,
fontWeight: FontWeight.w500,
height: 1.4,
letterSpacing: 0,
color: AppColors.primary,
decoration: TextDecoration.underline,
);

// ═══════════════════════════════════════════════════════════════
// Subtitle Styles
// ═══════════════════════════════════════════════════════════════

static TextStyle subtitle1 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 16,
fontWeight: FontWeight.w500,
height: 1.5,
letterSpacing: 0.15,
color: AppColors.textPrimary,
);

static TextStyle subtitle2 = TextStyle(
fontFamily: \_fontFamily,
fontSize: 14,
fontWeight: FontWeight.w500,
height: 1.5,
letterSpacing: 0.1,
color: AppColors.textSecondary,
);

static const String \_heading = 'Nunito';
static const String \_body = 'Inter';
static const TextStyle headline = TextStyle(
fontFamily: \_heading,
fontSize: 20,
fontWeight: FontWeight.w600,
height: 1.3,
letterSpacing: -0.1,
color: AppColors.textPrimary,
);

static const TextStyle title = TextStyle(
fontFamily: \_body,
fontSize: 18,
fontWeight: FontWeight.w600,
height: 1.4,
letterSpacing: 0,
color: AppColors.textPrimary,
);
static const TextStyle subtitle = TextStyle(
fontFamily: \_body,
fontSize: 16,
fontWeight: FontWeight.w500,
height: 1.5,
letterSpacing: 0,
color: AppColors.textSecondary,
);
static const TextStyle input = TextStyle(
fontFamily: \_body,
fontSize: 16,
fontWeight: FontWeight.w400,
height: 1.5,
letterSpacing: 0,
color: AppColors.textPrimary,
);
static const TextStyle helper = TextStyle(
fontFamily: \_body,
fontSize: 12,
fontWeight: FontWeight.w400,
height: 1.5,
letterSpacing: 0.1,
color: AppColors.textTertiary,
);
}

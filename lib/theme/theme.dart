// ignore_for_file: unused_field — token fields preserved for direct reference in widget code

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Font placeholders — replace with actual font families after adding .ttf/.otf
// files and registering them in pubspec.yaml
// ═══════════════════════════════════════════════════════════════════════════════
class FontFamily {
  FontFamily._();

  /// Serif placeholder (EB Garamond) — display, headlines, titles
  static const String serif = 'EnglishLiterature';

  /// Sans-serif placeholder — body copy, labels, UI elements
  static const String sans = 'GoogleSans';
}

// ═══════════════════════════════════════════════════════════════════════════════
// Spacing tokens
// ═══════════════════════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();

  /// Base spacing unit (8px scale)
  static const double base = 8.0;

  /// Maximum content width on desktop
  static const double containerMax = 1280.0;

  /// Inner padding for containers
  static const double containerPadding = 32.0;

  /// Grid gutter width
  static const double gutter = 24.0;

  /// Page-level horizontal margin on desktop
  static const double marginDesktop = 64.0;

  /// Page-level horizontal margin on mobile
  static const double marginMobile = 16.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Border radius tokens (shared across both themes)
// ═══════════════════════════════════════════════════════════════════════════════
class AppRadius {
  AppRadius._();

  /// 0.5rem — small elements, tags
  static const double sm = 8.0;

  /// 1rem — default radius
  static const double def = 16.0;

  /// 1.5rem — medium cards, modals
  static const double md = 24.0;

  /// 2rem — large containers
  static const double lg = 32.0;

  /// 3rem — hero sections, main cards
  static const double xl = 48.0;

  /// Fully pill-shaped
  static const double full = 9999.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Color tokens — Liminal Dawn (dark)
// ═══════════════════════════════════════════════════════════════════════════════
class _DarkColors {
  _DarkColors._();

  static const Color surface = Color(0xFF111415);
  static const Color surfaceDim = Color(0xFF111415);
  static const Color surfaceBright = Color(0xFF373A3B);
  static const Color surfaceContainerLowest = Color(0xFF0C0F10);
  static const Color surfaceContainerLow = Color(0xFF191C1D);
  static const Color surfaceContainer = Color(0xFF1D2021);
  static const Color surfaceContainerHigh = Color(0xFF282A2B);
  static const Color surfaceContainerHighest = Color(0xFF323536);
  static const Color onSurface = Color(0xFFE1E3E4);
  static const Color onSurfaceVariant = Color(0xFFE0C0B0);
  static const Color inverseSurface = Color(0xFFE1E3E4);
  static const Color onInverseSurface = Color(0xFF2E3132);
  static const Color outline = Color(0xFFA78B7C);
  static const Color outlineVariant = Color(0xFF584236);
  static const Color surfaceTint = Color(0xFFFFB68E);

  static const Color primary = Color(0xFFFFB68E);
  static const Color onPrimary = Color(0xFF542200);
  static const Color primaryContainer = Color(0xFFFF770F);
  static const Color onPrimaryContainer = Color(0xFF5C2600);
  static const Color inversePrimary = Color(0xFF9C4500);

  static const Color secondary = Color(0xFFC0C7D5);
  static const Color onSecondary = Color(0xFF2A313C);
  static const Color secondaryContainer = Color(0xFF454C58);
  static const Color onSecondaryContainer = Color(0xFFB5BCCA);

  static const Color tertiary = Color(0xFFBDC7DC);
  static const Color onTertiary = Color(0xFF273141);
  static const Color tertiaryContainer = Color(0xFF959FB4);
  static const Color onTertiaryContainer = Color(0xFF2C3647);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color primaryFixed = Color(0xFFFFDBCA);
  static const Color primaryFixedDim = Color(0xFFFFB68E);
  static const Color onPrimaryFixed = Color(0xFF331200);
  static const Color onPrimaryFixedVariant = Color(0xFF773300);

  static const Color secondaryFixed = Color(0xFFDCE3F2);
  static const Color secondaryFixedDim = Color(0xFFC0C7D5);
  static const Color onSecondaryFixed = Color(0xFF151C27);
  static const Color onSecondaryFixedVariant = Color(0xFF404753);

  static const Color tertiaryFixed = Color(0xFFD9E3F9);
  static const Color tertiaryFixedDim = Color(0xFFBDC7DC);
  static const Color onTertiaryFixed = Color(0xFF121C2C);
  static const Color onTertiaryFixedVariant = Color(0xFF3D4759);

  static const Color background = Color(0xFF111415);
  static const Color onBackground = Color(0xFFE1E3E4);
  static const Color surfaceVariant = Color(0xFF323536);
}

// ═══════════════════════════════════════════════════════════════════════════════
// Color tokens — Janus Light (light)
// ═══════════════════════════════════════════════════════════════════════════════
class _LightColors {
  _LightColors._();

  static const Color surface = Color(0xFFFBF9F4);
  static const Color surfaceDim = Color(0xFFDBDAD5);
  static const Color surfaceBright = Color(0xFFFBF9F4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EE);
  static const Color surfaceContainer = Color(0xFFF0EEE9);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DD);
  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF5B403A);
  static const Color inverseSurface = Color(0xFF30312E);
  static const Color onInverseSurface = Color(0xFFF2F1EC);
  static const Color outline = Color(0xFF8F7069);
  static const Color outlineVariant = Color(0xFFE4BEB6);
  static const Color surfaceTint = Color(0xFFB72301);

  static const Color primary = Color(0xFFB72301);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFF5733);
  static const Color onPrimaryContainer = Color(0xFF580C00);
  static const Color inversePrimary = Color(0xFFFFB4A4);

  static const Color secondary = Color(0xFF5F5E5E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE2DFDE);
  static const Color onSecondaryContainer = Color(0xFF636262);

  static const Color tertiary = Color(0xFF00677C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF009FBD);
  static const Color onTertiaryContainer = Color(0xFF002F3A);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color primaryFixed = Color(0xFFFFDAD3);
  static const Color primaryFixedDim = Color(0xFFFFB4A4);
  static const Color onPrimaryFixed = Color(0xFF3D0600);
  static const Color onPrimaryFixedVariant = Color(0xFF8C1800);

  static const Color secondaryFixed = Color(0xFFE5E2E1);
  static const Color secondaryFixedDim = Color(0xFFC8C6C5);
  static const Color onSecondaryFixed = Color(0xFF1C1B1B);
  static const Color onSecondaryFixedVariant = Color(0xFF474746);

  static const Color tertiaryFixed = Color(0xFFB0ECFF);
  static const Color tertiaryFixedDim = Color(0xFF60D5F5);
  static const Color onTertiaryFixed = Color(0xFF001F27);
  static const Color onTertiaryFixedVariant = Color(0xFF004E5E);

  static const Color background = Color(0xFFFBF9F4);
  static const Color onBackground = Color(0xFF1B1C19);
  static const Color surfaceVariant = Color(0xFFE4E2DD);
}

// ═══════════════════════════════════════════════════════════════════════════════
// Typography — union of both design systems.
// All font families use FontFamily placeholders; identical level = same spec
// across both themes.
// ═══════════════════════════════════════════════════════════════════════════════
abstract class _TypographyTokens {
  _TypographyTokens._();

  // ── Display ─────────────────────────────────────────────────────────────

  /// display-lg — 64px serif, editorial hero moments (from dark theme)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: FontFamily.serif,
    fontSize: 64,
    fontWeight: FontWeight.w500,
    height: 72 / 64, // 72px line-height
    letterSpacing: -0.02 * 64, // -0.02em at 64px ≈ -1.28
  );

  // ── Headlines ───────────────────────────────────────────────────────────

  /// headline-xl — 48px serif (from light theme)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: FontFamily.serif,
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 56 / 48, // 56px line-height
    letterSpacing: -0.02 * 48, // -0.02em at 48px ≈ -0.96
  );

  /// headline-lg — 40px serif (dark theme value, elected)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: FontFamily.serif,
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 48 / 40, // 48px line-height
  );

  /// headline-lg-mobile — 32px serif (dark theme value, elected)
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: FontFamily.serif,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 40 / 32, // 40px line-height
  );

  // ── Titles ──────────────────────────────────────────────────────────────

  /// title-md — 24px serif, editorial subheads (from dark theme)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: FontFamily.serif,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24, // 32px line-height
  );

  // ── Body ────────────────────────────────────────────────────────────────

  /// body-lg — 18px sans, long-form reading (from dark theme)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: FontFamily.sans,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18, // 28px line-height
  );

  /// body-md — 16px sans, primary UI copy
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: FontFamily.sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16, // 24px line-height
  );

  // ── Labels ──────────────────────────────────────────────────────────────

  /// label-md — 14px sans, UI labels (from light theme)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: FontFamily.sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14, // 20px line-height
    letterSpacing: 0.05 * 14, // 0.05em at 14px ≈ 0.7
  );

  /// label-sm — 12px sans, small UI captions (from dark theme)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: FontFamily.sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12, // 16px line-height
    letterSpacing: 0.05 * 12, // 0.05em at 12px ≈ 0.6
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ColorScheme builders
// ═══════════════════════════════════════════════════════════════════════════════

ColorScheme _darkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: _DarkColors.primary,
    onPrimary: _DarkColors.onPrimary,
    primaryContainer: _DarkColors.primaryContainer,
    onPrimaryContainer: _DarkColors.onPrimaryContainer,
    primaryFixed: _DarkColors.primaryFixed,
    primaryFixedDim: _DarkColors.primaryFixedDim,
    onPrimaryFixed: _DarkColors.onPrimaryFixed,
    onPrimaryFixedVariant: _DarkColors.onPrimaryFixedVariant,
    secondary: _DarkColors.secondary,
    onSecondary: _DarkColors.onSecondary,
    secondaryContainer: _DarkColors.secondaryContainer,
    onSecondaryContainer: _DarkColors.onSecondaryContainer,
    secondaryFixed: _DarkColors.secondaryFixed,
    secondaryFixedDim: _DarkColors.secondaryFixedDim,
    onSecondaryFixed: _DarkColors.onSecondaryFixed,
    onSecondaryFixedVariant: _DarkColors.onSecondaryFixedVariant,
    tertiary: _DarkColors.tertiary,
    onTertiary: _DarkColors.onTertiary,
    tertiaryContainer: _DarkColors.tertiaryContainer,
    onTertiaryContainer: _DarkColors.onTertiaryContainer,
    tertiaryFixed: _DarkColors.tertiaryFixed,
    tertiaryFixedDim: _DarkColors.tertiaryFixedDim,
    onTertiaryFixed: _DarkColors.onTertiaryFixed,
    onTertiaryFixedVariant: _DarkColors.onTertiaryFixedVariant,
    error: _DarkColors.error,
    onError: _DarkColors.onError,
    errorContainer: _DarkColors.errorContainer,
    onErrorContainer: _DarkColors.onErrorContainer,
    surface: _DarkColors.surface,
    onSurface: _DarkColors.onSurface,
    onSurfaceVariant: _DarkColors.onSurfaceVariant,
    surfaceDim: _DarkColors.surfaceDim,
    surfaceBright: _DarkColors.surfaceBright,
    surfaceContainerLowest: _DarkColors.surfaceContainerLowest,
    surfaceContainerLow: _DarkColors.surfaceContainerLow,
    surfaceContainer: _DarkColors.surfaceContainer,
    surfaceContainerHigh: _DarkColors.surfaceContainerHigh,
    surfaceContainerHighest: _DarkColors.surfaceContainerHighest,
    inverseSurface: _DarkColors.inverseSurface,
    onInverseSurface: _DarkColors.onInverseSurface,
    inversePrimary: _DarkColors.inversePrimary,
    outline: _DarkColors.outline,
    outlineVariant: _DarkColors.outlineVariant,
    surfaceTint: _DarkColors.surfaceTint,
  );
}

ColorScheme _lightColorScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    primary: _LightColors.primary,
    onPrimary: _LightColors.onPrimary,
    primaryContainer: _LightColors.primaryContainer,
    onPrimaryContainer: _LightColors.onPrimaryContainer,
    primaryFixed: _LightColors.primaryFixed,
    primaryFixedDim: _LightColors.primaryFixedDim,
    onPrimaryFixed: _LightColors.onPrimaryFixed,
    onPrimaryFixedVariant: _LightColors.onPrimaryFixedVariant,
    secondary: _LightColors.secondary,
    onSecondary: _LightColors.onSecondary,
    secondaryContainer: _LightColors.secondaryContainer,
    onSecondaryContainer: _LightColors.onSecondaryContainer,
    secondaryFixed: _LightColors.secondaryFixed,
    secondaryFixedDim: _LightColors.secondaryFixedDim,
    onSecondaryFixed: _LightColors.onSecondaryFixed,
    onSecondaryFixedVariant: _LightColors.onSecondaryFixedVariant,
    tertiary: _LightColors.tertiary,
    onTertiary: _LightColors.onTertiary,
    tertiaryContainer: _LightColors.tertiaryContainer,
    onTertiaryContainer: _LightColors.onTertiaryContainer,
    tertiaryFixed: _LightColors.tertiaryFixed,
    tertiaryFixedDim: _LightColors.tertiaryFixedDim,
    onTertiaryFixed: _LightColors.onTertiaryFixed,
    onTertiaryFixedVariant: _LightColors.onTertiaryFixedVariant,
    error: _LightColors.error,
    onError: _LightColors.onError,
    errorContainer: _LightColors.errorContainer,
    onErrorContainer: _LightColors.onErrorContainer,
    surface: _LightColors.surface,
    onSurface: _LightColors.onSurface,
    onSurfaceVariant: _LightColors.onSurfaceVariant,
    surfaceDim: _LightColors.surfaceDim,
    surfaceBright: _LightColors.surfaceBright,
    surfaceContainerLowest: _LightColors.surfaceContainerLowest,
    surfaceContainerLow: _LightColors.surfaceContainerLow,
    surfaceContainer: _LightColors.surfaceContainer,
    surfaceContainerHigh: _LightColors.surfaceContainerHigh,
    surfaceContainerHighest: _LightColors.surfaceContainerHighest,
    inverseSurface: _LightColors.inverseSurface,
    onInverseSurface: _LightColors.onInverseSurface,
    inversePrimary: _LightColors.inversePrimary,
    outline: _LightColors.outline,
    outlineVariant: _LightColors.outlineVariant,
    surfaceTint: _LightColors.surfaceTint,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TextTheme builder (shared typography across both themes)
// ═══════════════════════════════════════════════════════════════════════════════

TextTheme _buildTextTheme(ColorScheme cs) {
  return TextTheme(
    // ── Display ─────────────────────────────────────────────────────────
    displayLarge: _TypographyTokens.displayLarge.copyWith(color: cs.onSurface),

    // ── Headlines ───────────────────────────────────────────────────────
    headlineLarge: _TypographyTokens.headlineLarge.copyWith(
      color: cs.onSurface,
    ),
    headlineMedium: _TypographyTokens.headlineMedium.copyWith(
      color: cs.onSurface,
    ),
    headlineSmall: _TypographyTokens.headlineSmall.copyWith(
      color: cs.onSurface,
    ),

    // ── Titles ──────────────────────────────────────────────────────────
    titleMedium: _TypographyTokens.titleMedium.copyWith(color: cs.onSurface),

    // ── Body ────────────────────────────────────────────────────────────
    bodyLarge: _TypographyTokens.bodyLarge.copyWith(color: cs.onSurface),
    bodyMedium: _TypographyTokens.bodyMedium.copyWith(color: cs.onSurface),

    // ── Labels ──────────────────────────────────────────────────────────
    labelLarge: _TypographyTokens.labelLarge.copyWith(color: cs.onSurface),
    labelSmall: _TypographyTokens.labelSmall.copyWith(color: cs.onSurface),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Component theme builders
// ═══════════════════════════════════════════════════════════════════════════════

FilledButtonThemeData _buildFilledButtonTheme(ColorScheme cs) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      // Dawn Orange solid fill (primaryContainer per brand spec)
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.base * 2, // 16px
      ),
      textStyle: _TypographyTokens.labelLarge.copyWith(
        color: cs.onPrimaryContainer,
      ),
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme(
  ColorScheme cs,
  Brightness brightness,
) {
  // Dark: glass-morphic (translucent bg + white border)
  // Light: standard outlined
  final bool isDark = brightness == Brightness.dark;

  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: isDark
          ? cs.onSurface.withValues(alpha: 0.06)
          : Colors.transparent,
      foregroundColor: cs.onSurface,
      side: BorderSide(
        color: isDark ? cs.onSurface.withValues(alpha: 0.24) : cs.outline,
        width: 1,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.base * 2, // 16px
      ),
      textStyle: _TypographyTokens.labelLarge.copyWith(color: cs.onSurface),
    ),
  );
}

InputDecorationTheme _buildInputDecorationTheme(
  ColorScheme cs,
  Brightness brightness,
) {
  final bool isDark = brightness == Brightness.dark;

  if (isDark) {
    // Ghost-style: transparent fill, bottom border only
    return InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base * 2, // 16px
        vertical: AppSpacing.base * 1.5, // 12px
      ),
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      hintStyle: _TypographyTokens.bodyMedium.copyWith(
        color: cs.onSurface.withValues(alpha: 0.48),
      ),
      labelStyle: _TypographyTokens.labelLarge.copyWith(
        color: cs.onSurfaceVariant,
      ),
    );
  } else {
    // Light: soft-filled, pill-shaped
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base * 2.5, // 20px
        vertical: AppSpacing.base * 1.5, // 12px
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      hintStyle: _TypographyTokens.bodyMedium.copyWith(
        color: cs.onSurface.withValues(alpha: 0.48),
      ),
      labelStyle: _TypographyTokens.labelLarge.copyWith(
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

CardThemeData _buildCardTheme(ColorScheme cs, Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  return CardThemeData(
    color: cs.surfaceContainerHigh,
    elevation: isDark ? 0 : 2,
    shadowColor: isDark
        ? Colors.transparent
        : cs.primary.withValues(alpha: 0.06),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl), // 48px
      side: isDark
          ? BorderSide(color: cs.onSurface.withValues(alpha: 0.10), width: 1)
          : BorderSide.none,
    ),
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.gutter,
      vertical: AppSpacing.base, // 8px
    ),
  );
}

ChipThemeData _buildChipThemeData(ColorScheme cs) {
  return ChipThemeData(
    backgroundColor: cs.surfaceContainerHigh,
    selectedColor: cs.primaryContainer,
    labelStyle: _TypographyTokens.labelSmall.copyWith(color: cs.onSurface),
    secondaryLabelStyle: _TypographyTokens.labelSmall.copyWith(
      color: cs.onPrimaryContainer,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
    ),
    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.base * 1.5, // 12px
      vertical: AppSpacing.base * 0.5, // 4px
    ),
  );
}

ListTileThemeData _buildListTileTheme(ColorScheme cs) {
  return ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.gutter,
      vertical: AppSpacing.base, // 8px
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md), // 24px
    ),
    // Soft, rounded highlight — selected / hover states
    selectedColor: cs.primaryContainer.withValues(alpha: 0.12),
    selectedTileColor: cs.primaryContainer.withValues(alpha: 0.12),
    tileColor: cs.surface,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ThemeData builders
// ═══════════════════════════════════════════════════════════════════════════════

ThemeData _buildDarkTheme() {
  final ColorScheme cs = _darkColorScheme();
  const Brightness brightness = Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: cs,
    scaffoldBackgroundColor: _DarkColors.background,
    textTheme: _buildTextTheme(cs),
    // ── Component themes ──────────────────────────────────────────────────
    filledButtonTheme: _buildFilledButtonTheme(cs),
    outlinedButtonTheme: _buildOutlinedButtonTheme(cs, brightness),
    inputDecorationTheme: _buildInputDecorationTheme(cs, brightness),
    cardTheme: _buildCardTheme(cs, brightness),
    chipTheme: _buildChipThemeData(cs),
    listTileTheme: _buildListTileTheme(cs),
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant.withValues(alpha: 0.4),
      thickness: 0, // use padding-based separation
      space: AppSpacing.base,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: _TypographyTokens.titleMedium.copyWith(
        color: cs.onSurface,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cs.surfaceContainer,
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  );
}

ThemeData _buildLightTheme() {
  final ColorScheme cs = _lightColorScheme();
  const Brightness brightness = Brightness.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: cs,
    scaffoldBackgroundColor: _LightColors.background,
    textTheme: _buildTextTheme(cs),
    // ── Component themes ──────────────────────────────────────────────────
    filledButtonTheme: _buildFilledButtonTheme(cs),
    outlinedButtonTheme: _buildOutlinedButtonTheme(cs, brightness),
    inputDecorationTheme: _buildInputDecorationTheme(cs, brightness),
    cardTheme: _buildCardTheme(cs, brightness),
    chipTheme: _buildChipThemeData(cs),
    listTileTheme: _buildListTileTheme(cs),
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant.withValues(alpha: 0.4),
      thickness: 0, // use padding-based separation
      space: AppSpacing.base,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: _TypographyTokens.titleMedium.copyWith(
        color: cs.onSurface,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cs.surfaceContainer,
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Public API
// ═══════════════════════════════════════════════════════════════════════════════

/// Complete design system theme for the Janus app.
///
/// ## Usage in MaterialApp (auto-switch via system brightness)
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
///   …
/// )
/// ```
///
/// ## Manual selection
/// ```dart
/// Theme(
///   data: AppTheme.forBrightness(Theme.of(context).brightness),
///   child: …,
/// )
/// ```
///
/// ## Direct token access
/// ```dart
/// SizedBox(width: AppSpacing.base * 2);
/// Container(borderRadius: BorderRadius.circular(AppRadius.xl));
/// ```
class AppTheme {
  AppTheme._();

  /// Light theme (Janus Light)
  static final ThemeData light = _buildLightTheme();

  /// Dark theme (Liminal Dawn)
  static final ThemeData dark = _buildDarkTheme();

  /// Returns the theme matching the given [brightness].
  static ThemeData forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// Returns the theme for the current platform brightness.
  ///
  /// Requires a [BuildContext] with a [MediaQuery] ancestor.
  static ThemeData of(BuildContext context) {
    return forBrightness(MediaQuery.of(context).platformBrightness);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Re-exports for direct token access in widgets
// ═══════════════════════════════════════════════════════════════════════════════

/// Direct access to dark theme color tokens.
/// ```dart
/// Container(color: DarkColors.primaryContainer)
/// ```
typedef DarkColors = _DarkColors;

/// Direct access to light theme color tokens.
/// ```dart
/// Container(color: LightColors.surfaceContainerHigh)
/// ```
typedef LightColors = _LightColors;

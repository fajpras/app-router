import 'package:flutter/material.dart';

/// Color tokens extracted from the Stitch "9Router Mobile UI Kit" design system.
class RouterColors {
  RouterColors._();

  static const Color surface = Color(0xFF12131A);
  static const Color surfaceContainerLowest = Color(0xFF0D0E15);
  static const Color surfaceContainerLow = Color(0xFF1A1B22);
  static const Color surfaceContainer = Color(0xFF1E1F26);
  static const Color surfaceContainerHigh = Color(0xFF292931);
  static const Color surfaceContainerHighest = Color(0xFF34343C);

  static const Color primary = Color(0xFFB7C4FF);
  static const Color primaryContainer = Color(0xFF7B96FF);
  static const Color secondary = Color(0xFFD6BAFF);
  static const Color tertiary = Color(0xFF55E16B);
  static const Color warning = Color(0xFFF2C94C);
  static const Color error = Color(0xFFFF4D4F);
  static const Color errorSurface = Color(0xFFB71C1C);

  static const Color onSurface = Color(0xFFE3E1EC);
  static const Color onSurfaceVariant = Color(0xFFC5C5D5);
  static const Color outline = Color(0xFF8E909E);
  static const Color outlineVariant = Color(0xFF444653);

  static const Color splashIconBg = Color(0xFF1E2130);
  static const Color splashIconBorder = Color(0xFF2D324A);
  static const Color loginAccent = Color(0xFF008272);
  static const Color loginFocusBorder = Color(0xFF00897B);
}

ThemeData buildRouterTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RouterColors.surface,
    colorScheme: const ColorScheme.dark(
      surface: RouterColors.surface,
      primary: RouterColors.primary,
      primaryContainer: RouterColors.primaryContainer,
      secondary: RouterColors.secondary,
      tertiary: RouterColors.tertiary,
      error: RouterColors.error,
      onSurface: RouterColors.onSurface,
      onSurfaceVariant: RouterColors.onSurfaceVariant,
      outline: RouterColors.outline,
      outlineVariant: RouterColors.outlineVariant,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: RouterColors.surface,
      foregroundColor: RouterColors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: RouterColors.surfaceContainerHigh,
      contentTextStyle: const TextStyle(color: RouterColors.onSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

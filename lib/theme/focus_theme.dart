import 'package:flutter/material.dart';

/// Provisional palette: feature widgets contain no hex colors.
abstract final class FocusTokens {
  static const fontFamily = 'Focus UI';
  // Duolingo-inspired energy: vivid semantic colors on a quiet white canvas.
  // These are product tokens, not a copy of Duolingo branding.
  static const canvas = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF4B4B4B);
  static const muted = Color(0xFF777777);
  static const line = Color(0xFFE5E5E5);
  static const accent = Color(0xFF1CB0F6);
  static const accentLight = Color(0xFFE8F8E1);
  static const actionPrimary = Color(0xFF58CC02);
  static const onActionPrimary = Color(0xFFFFFFFF);
  static const actionPrimaryDepth = Color(0xFF46A302);
  static const actionDisabled = Color(0xFFE5E5E5);
  static const actionDisabledDepth = Color(0xFFD0D0D0);
  static const onActionDisabled = muted;
  static const darkSurface = Color(0xFF235390);
  static const onDark = Color(0xFFFFFFFF);
  static const onDarkMuted = Color(0xFFD7EEFF);
  static const sage = Color(0xFFE8F8E1);
  static const gold = Color(0xFFFFC800);
  static const pagePadding = 24.0;
  static const cardRadius = 16.0;
  static const primaryButtonFaceHeight = 58.0;
  static const primaryButtonDepth = 8.0;
  static const primaryButtonPressedTravel = 7.0;
  static const primaryButtonRadius = 14.0;
  static const maxWidth = 480.0;
}

ThemeData focusTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: FocusTokens.accent,
    brightness: Brightness.light,
    primary: FocusTokens.ink,
    onPrimary: FocusTokens.surface,
    secondary: FocusTokens.accent,
    surface: FocusTokens.surface,
    onSurface: FocusTokens.ink,
    onSurfaceVariant: FocusTokens.muted,
    outlineVariant: FocusTokens.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: FocusTokens.canvas,
    fontFamily: FocusTokens.fontFamily,
    fontFamilyFallback: const ['PingFang SC', 'Noto Sans SC', 'sans-serif'],
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.65),
      bodyMedium: TextStyle(fontSize: 13, height: 1.6),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ).apply(bodyColor: FocusTokens.ink, displayColor: FocusTokens.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: FocusTokens.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: FocusTokens.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: FocusTokens.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: FocusTokens.sage,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: FocusTokens.fontFamily,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? FocusTokens.ink
              : FocusTokens.muted,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: FocusTokens.line, thickness: 1),
  );
}

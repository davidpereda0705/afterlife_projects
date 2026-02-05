// lib/core/themes/afterlife_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_theme.dart';

class AfterlifeTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // Colores
      scaffoldBackgroundColor: AfterlifeColors.background,
      canvasColor: AfterlifeColors.background,
      cardColor: Colors.white.withOpacity(0.05),
      
      // ColorScheme
      colorScheme: const ColorScheme.dark(
        primary: AfterlifeColors.electricPurple,
        secondary: AfterlifeColors.neonPink,
        surface: AfterlifeColors.surfaceDark,
        background: AfterlifeColors.background,
        onSurface: AfterlifeColors.textPrimary,
      ),
      
      // Text Theme (usa AfterlifeTextTheme)
      textTheme: TextTheme(
        displayLarge: AfterlifeTextTheme.displayLarge,
        displayMedium: AfterlifeTextTheme.displayMedium,
        headlineLarge: AfterlifeTextTheme.headlineLarge,
        headlineMedium: AfterlifeTextTheme.headlineMedium,
        titleLarge: AfterlifeTextTheme.titleLarge,
        titleMedium: AfterlifeTextTheme.titleMedium,
        titleSmall: AfterlifeTextTheme.titleSmall,
        bodyLarge: AfterlifeTextTheme.bodyLarge,
        bodyMedium: AfterlifeTextTheme.bodyMedium,
        bodySmall: AfterlifeTextTheme.bodySmall,
        labelLarge: AfterlifeTextTheme.labelLarge,
        labelMedium: AfterlifeTextTheme.labelMedium,
        labelSmall: AfterlifeTextTheme.labelSmall,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AfterlifeTextTheme.fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AfterlifeColors.textPrimary,
        ),
      ),
      
      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AfterlifeColors.electricPurple,
          foregroundColor: AfterlifeColors.textPrimary,
          textStyle: AfterlifeTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
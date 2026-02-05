// lib/core/themes/text_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart'; // Importa colors para usar los colores

class AfterlifeTextTheme {
  static const String fontFamily = 'Syne';
  
  // Display
  static TextStyle displayLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle displayMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w600,
    color: AfterlifeColors.textPrimary,
  );
  
  // Headline
  static TextStyle headlineLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle headlineMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textPrimary,
  );
  
  // Title
  static TextStyle titleLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle titleMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle titleSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textPrimary,
  );
  
  // Body
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AfterlifeColors.textSecondary,
  );
  
  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AfterlifeColors.textDisabled,
  );
  
  // Label
  static TextStyle labelLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle labelMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textPrimary,
  );
  
  static TextStyle labelSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AfterlifeColors.textSecondary,
  );
}
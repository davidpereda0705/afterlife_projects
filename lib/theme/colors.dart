// lib/core/themes/colors.dart
import 'package:flutter/material.dart';

class AfterlifeColors {
  // Fondo
  static const Color background = Color(0xFF0D0D0D);
  
  // Paleta neón
  static const Color electricPurple = Color(0xFFA855F7);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color cyanBlue = Color(0xFF06B6D4);
  static const Color acidGreen = Color(0xFF84CC16);
  static const Color neonOrange = Color(0xFFF59E0B);
  static const Color deepPurple = Color(0xFF8B5CF6);
  
  // Texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color textDisabled = Color(0xFF666680);
  
  // Superficies
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF1E1E2D);
  
  // Métodos de ayuda
  static Color electricPurpleWithOpacity(double opacity) => 
      electricPurple.withOpacity(opacity);
      
  static Color neonPinkWithOpacity(double opacity) => 
      neonPink.withOpacity(opacity);
      
  static Color cyanBlueWithOpacity(double opacity) => 
      cyanBlue.withOpacity(opacity);
  
  // Gradientes
  static Gradient get purplePinkGradient => LinearGradient(
    colors: [electricPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static Gradient get blueGreenGradient => LinearGradient(
    colors: [cyanBlue, acidGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static Gradient get orangePurpleGradient => LinearGradient(
    colors: [neonOrange, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
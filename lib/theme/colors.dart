// lib/core/themes/colors.dart
import 'package:flutter/material.dart';

class AfterlifeColors {
  // =================== DARK ===================
  // Fondo
  static const Color background = Color(0xFF000000);

  // Paleta neón
  static const Color electricPurple = Color(0xFFA855F7);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color cyanBlue = Color(0xFF06B6D4);
  static const Color acidGreen = Color(0xFF84CC16);
  static const Color neonOrange = Color(0xFFF59E0B);
  static const Color deepPurple = Color(0xFF8B5CF6);

  // Lila eléctrico
  static const Color electricLilac = Color(0xFF7B1FA2);

  // Texto
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textDisabled = Color(0xFF555555);

  // Superficies
  static const Color surfaceDark = Color(0xFF000000);
  static const Color cardDark = Color(0xFF000000);

  // =================== LIGHT ===================
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;

  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6E6E73);
  static const Color textDisabledLight = Color(0xFFB0B0B8);

  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color outlineLight = Color(0xFFD1D1D6);
  static const Color shadowLight = Color(0x1F000000);

  static const Color inputFillLight = Color(0xFFF2F2F7);
  
  // Métodos de ayuda
  static Color electricPurpleWithOpacity(double opacity) => 
      electricPurple.withOpacity(opacity);
      
  static Color neonPinkWithOpacity(double opacity) => 
      neonPink.withOpacity(opacity);
      
  static Color cyanBlueWithOpacity(double opacity) => 
      cyanBlue.withOpacity(opacity);
      
  static Color electricLilacWithOpacity(double opacity) => 
      electricLilac.withOpacity(opacity);
  
  // Gradientes (añadimos uno con tu nuevo color)
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
  
  // NUEVO: Gradiente con tu lila eléctrico
  static Gradient get electricLilacGradient => LinearGradient(
    colors: [electricLilac, Color(0xFF9C27B0)], // Lila eléctrico a magenta
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
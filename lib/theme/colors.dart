// Paleta de colores, gradientes y utilidades de tema para toda la app.
import 'package:flutter/material.dart';

class AfterlifeColors {
  // =================== DARK ===================
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
  static const Color cardDark = Color(0xFF0D0D1A);

  // =================== LIGHT ===================
  static const Color backgroundLight = Color(0xFFF8F5FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  static const Color textPrimaryLight = Color(0xFF1A0A2E);
  static const Color textSecondaryLight = Color(0xFF6B5B7F);
  static const Color textDisabledLight = Color(0xFFB0A8BC);

  static const Color dividerLight = Color(0xFFE8E0F0);
  static const Color outlineLight = Color(0xFFD4CCE6);
  static const Color shadowLight = Color(0x1F000000);

  static const Color inputFillLight = Color(0xFFF2EDFA);

  // =================== HELPERS ===================
  static Color electricPurpleWithOpacity(double opacity) =>
      electricPurple.withValues(alpha: opacity);

  static Color neonPinkWithOpacity(double opacity) =>
      neonPink.withValues(alpha: opacity);

  static Color cyanBlueWithOpacity(double opacity) =>
      cyanBlue.withValues(alpha: opacity);

  static Color electricLilacWithOpacity(double opacity) =>
      electricLilac.withValues(alpha: opacity);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color card(BuildContext context) =>
      isDark(context) ? cardDark : cardLight;

  static Color textPrimaryAdaptive(BuildContext context) =>
      isDark(context) ? textPrimary : textPrimaryLight;

  static Color textSecondaryAdaptive(BuildContext context) =>
      isDark(context) ? textSecondary : textSecondaryLight;

  static Color textDisabledAdaptive(BuildContext context) =>
      isDark(context) ? textDisabled : textDisabledLight;

  static Color dividerAdaptive(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.05) : dividerLight;

  static Color outlineAdaptive(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.1) : outlineLight;

  static Color inputFillAdaptive(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.03) : inputFillLight;

  // =================== GRADIENTS ===================
  static Gradient get gradient => const LinearGradient(
    colors: [electricPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  static Gradient get purplePinkGradient => const LinearGradient(
    colors: [electricPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get blueGreenGradient => const LinearGradient(
    colors: [cyanBlue, acidGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get orangePurpleGradient => const LinearGradient(
    colors: [neonOrange, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get electricLilacGradient => const LinearGradient(
    colors: [electricLilac, Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get heroGradient => const LinearGradient(
    colors: [electricPurple, neonPink, cyanBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Adaptive header gradient
  static Gradient headerGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        colors: [Color(0xFF1A0533), Color(0xFF0D0D1A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFF3E8FF), Color(0xFFFFF0F5), Color(0xFFE0F7FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Adaptive card gradient for profile/home cards
  static Gradient cardGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        colors: [Color(0xFF1A0533), Color(0xFF2D0A4E), Color(0xFF1A0533)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFFAF5FF), Color(0xFFFFF5FA)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Adaptive subtle card gradient
  static Gradient subtleCardGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        colors: [Color(0xFF1A0533), Color(0xFF0A0A14)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Bottom nav gradient
  static Gradient bottomNavGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        colors: [Color(0xFF0D0D1A), Color(0xFF060610)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F5FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

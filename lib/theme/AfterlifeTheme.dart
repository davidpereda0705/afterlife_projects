// lib/core/themes/afterlife_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_theme.dart';

class AfterlifeTheme {
  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Base tokens
    final Color background = isDark
        ? AfterlifeColors.background
        : AfterlifeColors.backgroundLight;
    final Color surface = isDark
        ? AfterlifeColors.surfaceDark
        : AfterlifeColors.surfaceLight;
    final Color card = isDark
        ? AfterlifeColors.cardDark
        : AfterlifeColors.cardLight;
    final Color textPrimary = isDark
        ? AfterlifeColors.textPrimary
        : AfterlifeColors.textPrimaryLight;
    final Color textSecondary = isDark
        ? AfterlifeColors.textSecondary
        : AfterlifeColors.textSecondaryLight;
    final Color textDisabled = isDark
        ? AfterlifeColors.textDisabled
        : AfterlifeColors.textDisabledLight;
    final Color divider = isDark ? Colors.white.withOpacity(0.05) : AfterlifeColors.dividerLight;
    final Color outline = isDark ? Colors.white.withOpacity(0.1) : AfterlifeColors.outlineLight;
    final Color shadow = Colors.black;
    final Color inputFill = isDark
        ? Colors.white.withOpacity(0.03)
        : AfterlifeColors.inputFillLight;

    // Accent colors (shared)
    const Color primary = AfterlifeColors.electricPurple;
    const Color secondary = AfterlifeColors.neonPink;
    const Color error = Colors.redAccent;

    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.04),
      onSurfaceVariant: textSecondary,
      outline: outline,
      error: error,
      onError: Colors.white,
      shadow: shadow,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge:
          AfterlifeTextTheme.displayLarge.copyWith(color: textPrimary),
      displayMedium:
          AfterlifeTextTheme.displayMedium.copyWith(color: textPrimary),
      headlineLarge:
          AfterlifeTextTheme.headlineLarge.copyWith(color: textPrimary),
      headlineMedium:
          AfterlifeTextTheme.headlineMedium.copyWith(color: textPrimary),
      headlineSmall: AfterlifeTextTheme.headlineMedium.copyWith(
        fontSize: 24,
        color: textPrimary,
      ),
      titleLarge: AfterlifeTextTheme.titleLarge.copyWith(color: textPrimary),
      titleMedium: AfterlifeTextTheme.titleMedium.copyWith(color: textPrimary),
      titleSmall: AfterlifeTextTheme.titleSmall.copyWith(color: textPrimary),
      bodyLarge: AfterlifeTextTheme.bodyLarge.copyWith(color: textPrimary),
      bodyMedium:
          AfterlifeTextTheme.bodyMedium.copyWith(color: textSecondary),
      bodySmall: AfterlifeTextTheme.bodySmall.copyWith(
        color: textSecondary.withOpacity(0.7),
      ),
      labelLarge: AfterlifeTextTheme.labelLarge.copyWith(color: textPrimary),
      labelMedium: AfterlifeTextTheme.labelMedium.copyWith(color: textPrimary),
      labelSmall:
          AfterlifeTextTheme.labelSmall.copyWith(color: textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: background,
      cardColor: card,
      dividerColor: divider,
      disabledColor: textDisabled,
      hintColor: textDisabled,
      shadowColor: shadow,
      colorScheme: colorScheme,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: AfterlifeColors.electricLilac,
        unselectedItemColor: textDisabled,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle:
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        contentTextStyle: textTheme.bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? AfterlifeColors.surfaceDark
            : const Color(0xFF323232),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dividerTheme: DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textDisabled),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: error),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: AfterlifeTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AfterlifeTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      iconTheme: IconThemeData(color: textSecondary, size: 24),
      primaryIconTheme: IconThemeData(color: primary, size: 24),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.1),
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.12),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? Colors.grey.shade400 : Colors.grey.shade300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.5);
          }
          return isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.1);
        }),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

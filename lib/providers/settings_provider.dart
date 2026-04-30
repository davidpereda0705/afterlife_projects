import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _themeModeKey = 'dark'; // 'dark' | 'light'
  double _fontSizeFactor = 1.0;

  ThemeMode get themeMode {
    switch (_themeModeKey) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  String get themeModeKey => _themeModeKey;
  double get fontSizeFactor => _fontSizeFactor;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeModeKey') ?? 'dark';
    _themeModeKey = saved == 'system' ? 'dark' : saved;
    _fontSizeFactor = prefs.getDouble('fontSizeFactor') ?? 1.0;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    switch (mode) {
      case ThemeMode.light:
        _themeModeKey = 'light';
        break;

      case ThemeMode.dark:
      default:
        _themeModeKey = 'dark';
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeModeKey', _themeModeKey);
    notifyListeners();
  }

  Future<void> setFontSizeFactor(double factor) async {
    _fontSizeFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeFactor', factor);
    notifyListeners();
  }
}

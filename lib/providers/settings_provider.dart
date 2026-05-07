import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _themeModeKey = 'dark'; // 'dark' | 'light' | 'system'
  double _fontSizeFactor = 1.0;
  bool _backgroundEffects = true;
  bool _hapticFeedback = true;
  bool _notificationsEnabled = true;
  bool _compactMode = false;

  ThemeMode get themeMode {
    switch (_themeModeKey) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  String get themeModeKey => _themeModeKey;
  double get fontSizeFactor => _fontSizeFactor;
  bool get backgroundEffects => _backgroundEffects;
  bool get hapticFeedback => _hapticFeedback;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get compactMode => _compactMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeModeKey = prefs.getString('themeModeKey') ?? 'dark';
    _fontSizeFactor = prefs.getDouble('fontSizeFactor') ?? 1.0;
    _backgroundEffects = prefs.getBool('backgroundEffects') ?? true;
    _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _compactMode = prefs.getBool('compactMode') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(String key) async {
    _themeModeKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeModeKey', key);
    notifyListeners();
  }

  Future<void> setFontSizeFactor(double factor) async {
    _fontSizeFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeFactor', factor);
    notifyListeners();
  }

  Future<void> setBackgroundEffects(bool value) async {
    _backgroundEffects = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundEffects', value);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticFeedback', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setCompactMode(bool value) async {
    _compactMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compactMode', value);
    notifyListeners();
  }
}

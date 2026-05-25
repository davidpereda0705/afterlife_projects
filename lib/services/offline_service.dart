// Servicio de caché offline: guarda y recupera datos del usuario en SharedPreferences para uso sin conexión.
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio simple de cache offline usando SharedPreferences.
/// Ideal para guardar la noche activa y datos del usuario cuando no hay red.
class OfflineService {
  static const String _keyActiveNight = 'offline_active_night';
  static const String _keyUserData = 'offline_user_data';

  /// Convierte Timestamp/FieldValue/DateTime a valores JSON-serializables
  static dynamic _sanitize(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }
    if (value is FieldValue) {
      return DateTime.now().millisecondsSinceEpoch;
    }
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, _sanitize(v)));
    }
    if (value is List) {
      return value.map((v) => _sanitize(v)).toList();
    }
    return value;
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    return data.map((k, v) => MapEntry(k, _sanitize(v)));
  }

  static Future<void> cacheActiveNight(Map<String, dynamic> nightData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveNight, jsonEncode(_sanitizeMap(nightData)));
  }

  static Future<Map<String, dynamic>?> getCachedActiveNight() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyActiveNight);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> cacheUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(_sanitizeMap(userData)));
  }

  static Future<Map<String, dynamic>?> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveNight);
    await prefs.remove(_keyUserData);
  }
}

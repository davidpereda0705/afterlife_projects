// Proveedor central del estado del usuario autenticado (patrón Provider).
// Actúa como fuente de verdad para todos los datos de perfil en la app.
// Escucha cambios de sesión de Firebase Auth y sincroniza con Firestore.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:afterlife_projects/core/level_calculator.dart';
import 'package:afterlife_projects/services/offline_service.dart';
import 'package:afterlife_projects/utils/image_utils.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get activeNightId => _userData?['activeNightId'];

  // Firestore devuelve List<dynamic>, por eso el cast a Map
  List<Map<String, dynamic>> get unlockedAchievements {
    final list = _userData?['unlockedAchievements'];
    if (list is List) {
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProvider() {
    // Escucha cambios de sesión: carga datos al hacer login, los borra al cerrar sesión.
    // Esto evita tener que llamar manualmente a cargar datos desde cada pantalla.
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearUserData();
      } else {
        _loadUserData();
      }
    });
  }

  void _clearUserData() {
    _userData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _clearUserData();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fuerza renovar el token de autenticación antes de leer Firestore.
      // Sin esto, en Flutter Web Firestore puede rechazar la petición justo después del login
      // porque el token local todavía no está sincronizado.
      await _auth.currentUser?.getIdToken(true);

      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();

      Map<String, dynamic> data = {};
      if (doc.exists) {
        data = doc.data()!;
      } else {
        // Caso excepcional: usuario autenticado pero sin documento en Firestore.
        // Ocurre si el registro falló a medias. Se crea el documento con valores base.
        data = {
          'username': _auth.currentUser?.email?.split('@').first ?? 'Usuario',
          'email': _auth.currentUser?.email ?? '',
          'level': 1,
          'points': 0,
          'nightsCompleted': 0,
          'challengesCompleted': 0,
          'friendsCount': 0,
          'photosUploaded': 0,
          'nightsCreated': 0,
          'unlockedAchievements': [],
          'createdAt': FieldValue.serverTimestamp(),
        };
        await docRef.set(data);
      }

      // Migración de campos: si un usuario antiguo no tiene estos campos,
      // se añaden en local y luego se escribe solo UNA vez a Firestore (needsUpdate).
      // Así evitamos múltiples escrituras innecesarias en cada carga.
      bool needsUpdate = false;

      if (!data.containsKey('photosUploaded')) {
        data['photosUploaded'] = 0;
        needsUpdate = true;
      }
      if (!data.containsKey('nightsCreated')) {
        data['nightsCreated'] = 0;
        needsUpdate = true;
      }
      if (!data.containsKey('friendsCount')) {
        data['friendsCount'] = 0;
        needsUpdate = true;
      }
      if (!data.containsKey('unlockedAchievements')) {
        data['unlockedAchievements'] = [];
        needsUpdate = true;
      } else {
        // Sanea el array de logros: filtra entradas corruptas (sin 'achievementId').
        // Puede ocurrir si se guardó un logro con estructura incorrecta en versiones anteriores.
        final list = data['unlockedAchievements'];
        if (list is List) {
          final cleanList = list.where((item) {
            return item is Map && item.containsKey('achievementId');
          }).toList();
          if (cleanList.length != list.length) {
            data['unlockedAchievements'] = cleanList;
            needsUpdate = true;
          }
        } else {
          data['unlockedAchievements'] = [];
          needsUpdate = true;
        }
      }

      if (needsUpdate) {
        await docRef.update({
          'photosUploaded': data['photosUploaded'],
          'nightsCreated': data['nightsCreated'],
          'friendsCount': data['friendsCount'],
          'unlockedAchievements': data['unlockedAchievements'],
        });
      }

      _userData = data;
      _error = null;
      // Guarda los datos en caché local para que la app funcione sin conexión
      await OfflineService.cacheUserData(data);
    } catch (e) {
      _error = e.toString();
      // Modo offline: si Firestore falla, intenta usar la caché guardada en el dispositivo
      final cached = await OfflineService.getCachedUserData();
      if (cached != null) {
        _userData = cached;
        _error = null; // Con caché disponible, la app funciona con normalidad
      } else {
        _userData = null;
      }
      debugPrint('Error en _loadUserData: $e');
    } finally {
      // finally garantiza que _isLoading se pone a false y la UI se actualiza
      // tanto si hubo error como si no
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadUserData();
  }

  int _calculateLevel(int points) {
    return LevelCalculator.calculate(points);
  }

  // Marca una noche como activa en local y en Firestore simultáneamente.
  // La actualización local evita esperar el reload completo para refrescar la UI.
  Future<void> setActiveNight(String nightId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': nightId});
    if (_userData != null) {
      _userData!['activeNightId'] = nightId;
      notifyListeners();
    }
  }

  Future<void> clearActiveNight() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': null});
    if (_userData != null) {
      _userData!['activeNightId'] = null;
      notifyListeners();
    }
  }

  Future<void> updateUnlockedAchievements(List<Map<String, dynamic>> newList) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'unlockedAchievements': newList});
    if (_userData != null) {
      _userData!['unlockedAchievements'] = newList;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required String username,
    required String handle,
    File? avatarFile,
    String? avatarUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');

    if (username.trim().isEmpty) {
      throw Exception('El nombre de usuario no puede estar vacío');
    }
    if (!handle.startsWith('@') || handle.length < 2) {
      throw Exception('El handle debe empezar con @ y tener al menos un carácter');
    }

    final updateData = <String, dynamic>{
      'username': username.trim(),
      'handle': handle.trim(),
    };
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      updateData['avatarUrl'] = avatarUrl;
    }

    // La foto se comprime y guarda como bytes directamente en el documento de Firestore,
    // igual que las fotos de noche. Se evita Firebase Storage porque las reglas
    // de seguridad por defecto lo bloquean y esta app no necesita URLs públicas.
    if (avatarFile != null) {
      final raw = await avatarFile.readAsBytes();
      final Uint8List compressed = await ImageUtils.compressForFirestore(raw);
      updateData['avatarBytes'] = compressed;
    }

    try {
      await _firestore.collection('users').doc(userId).update(updateData);
      // Actualiza el mapa local para que la UI refleje el cambio sin hacer otro fetch
      if (_userData != null) {
        _userData!.addAll(updateData);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Llamado al terminar una noche: suma puntos, incrementa contadores y recalcula la racha.
  // Lee de Firestore en lugar de _userData para evitar datos stale si hubo cambios externos.
  Future<void> updateAfterNight({
    required int pointsEarned,
    required int nightsCompletedIncrement,
    required int challengesCompletedIncrement,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');

    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Usuario no encontrado');

      final data = doc.data()!;
      final currentPoints = data['points'] ?? 0;
      final currentNights = data['nightsCompleted'] ?? 0;
      final currentChallenges = data['challengesCompleted'] ?? 0;
      final currentLevel = data['level'] ?? 1;
      final currentStreak = data['streakCount'] ?? 0;
      final lastNightDate = data['lastNightDate'];

      final newPoints = currentPoints + pointsEarned;
      final newNights = currentNights + nightsCompletedIncrement;
      final newChallenges = currentChallenges + challengesCompletedIncrement;
      final newLevel = _calculateLevel(newPoints);

      // Lógica de racha: la racha sube si la última noche fue hoy o ayer.
      // Si fue hoy, significa que el usuario terminó dos noches en el mismo día (no rompe racha).
      // Si fue hace más de un día, la racha se reinicia a 1.
      int newStreak = 1;
      final now = DateTime.now();
      if (lastNightDate != null) {
        DateTime lastDate;
        if (lastNightDate is Timestamp) {
          lastDate = lastNightDate.toDate();
        } else if (lastNightDate is DateTime) {
          lastDate = lastNightDate;
        } else {
          // Tipo desconocido: asumir que la racha está rota
          lastDate = now.subtract(const Duration(days: 2));
        }
        // Comparamos solo la fecha (sin hora) para que no importe a qué hora se jugó
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final today = DateTime(now.year, now.month, now.day);
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        if (lastDay == yesterday || lastDay == today) {
          newStreak = currentStreak + 1;
        }
      }

      final updates = <String, dynamic>{
        'points': newPoints,
        'nightsCompleted': newNights,
        'challengesCompleted': newChallenges,
        'streakCount': newStreak,
        'lastNightDate': Timestamp.fromDate(now),
      };
      // Solo incluye 'level' en la escritura si realmente cambió, para no sobrescribir sin motivo
      if (newLevel != currentLevel) {
        updates['level'] = newLevel;
      }

      await docRef.update(updates);
      await refresh();
    } catch (e) {
      throw Exception('Error al actualizar estadísticas: $e');
    }
  }

  @override
  void dispose() {
    // Cancela la suscripción al stream de auth para evitar memory leaks
    _authSubscription?.cancel();
    super.dispose();
  }
}

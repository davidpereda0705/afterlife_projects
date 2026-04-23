import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Getter para la noche activa
  String? get activeNightId => _userData?['activeNightId'];
  
  // Getter para la lista de logros desbloqueados
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
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
        _error = null;
      } else {
        _userData = null;
        _error = 'Usuario no encontrado en Firestore';
      }
    } catch (e) {
      _error = e.toString();
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método público para forzar una recarga manual (útil si se edita el perfil)
  Future<void> refresh() async {
    await _loadUserData();
  }

  /// Calcula el nivel según los puntos totales.
  /// Fórmula: nivel = 1 + (puntos / 100). Ajusta según tu diseño.
  int _calculateLevel(int points) {
    return 1 + (points ~/ 100);
  }

  /// Establece la noche activa para el usuario
  Future<void> setActiveNight(String nightId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': nightId});
    await refresh();
  }

  /// Limpia la noche activa del usuario
  Future<void> clearActiveNight() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': null});
    await refresh();
  }

  /// Actualiza la lista de logros desbloqueados (usado por AchievementService)
  Future<void> updateUnlockedAchievements(List<Map<String, dynamic>> newList) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'unlockedAchievements': newList});
    await refresh();
  }

  Future<void> updateUserProfile({
    required String username,
    required String handle,
    File? avatarFile,
    String? avatarUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (username.trim().isEmpty) {
      throw Exception('El nombre de usuario no puede estar vacío');
    }
    if (!handle.startsWith('@') || handle.length < 2) {
      throw Exception('El handle debe empezar con @ y tener al menos un carácter');
    }

    Map<String, dynamic> updateData = {
      'username': username.trim(),
      'handle': handle.trim(),
    };

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      updateData['avatarUrl'] = avatarUrl;
    }

    try {
      await _firestore.collection('users').doc(userId).update(updateData);
      await refresh(); // Recargar los datos después de actualizar
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<void> updateAfterNight({
    required int pointsEarned,
    required int nightsCompletedIncrement,
    required int challengesCompletedIncrement,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final currentPoints = doc.data()?['points'] ?? 0;
      final currentNights = doc.data()?['nightsCompleted'] ?? 0;
      final currentChallenges = doc.data()?['challengesCompleted'] ?? 0;
      final currentLevel = doc.data()?['level'] ?? 1;

      final newPoints = currentPoints + pointsEarned;
      final newNights = currentNights + nightsCompletedIncrement;
      final newChallenges = currentChallenges + challengesCompletedIncrement;
      final newLevel = _calculateLevel(newPoints);

      final updates = {
        'points': newPoints,
        'nightsCompleted': newNights,
        'challengesCompleted': newChallenges,
      };
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
    _authSubscription?.cancel();
    super.dispose();
  }
}
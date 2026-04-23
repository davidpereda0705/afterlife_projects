import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../core/level_calculator.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get activeNightId => _userData?['activeNightId'];
  
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
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();

      Map<String, dynamic> data = {};
      if (doc.exists) {
        data = doc.data()!;
      } else {
        // Si el documento no existe (caso extremo), lo creamos con valores por defecto
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

      bool needsUpdate = false;

      // 1. Asegurar campos existentes
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
        // 2. Limpiar array de logros desbloqueados (eliminar elementos inválidos)
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

      // 3. Guardar cambios si es necesario
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
    } catch (e) {
      _error = e.toString();
      _userData = null;
      debugPrint('Error en _loadUserData: $e');
    } finally {
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

  Future<void> setActiveNight(String nightId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': nightId});
    await refresh();
  }

  Future<void> clearActiveNight() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': null});
    await refresh();
  }

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

    try {
      await _firestore.collection('users').doc(userId).update(updateData);
      await refresh();
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
    if (userId == null) throw Exception('No hay usuario autenticado');

    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Usuario no encontrado');

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
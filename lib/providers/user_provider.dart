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
  
  // ✅ Getter para la noche activa
  String? get activeNightId => _userData?['activeNightId'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProvider() {
    // Escuchar cambios en la autenticación (login/logout)
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

  Future<void> refresh() async {
    await _loadUserData();
  }

  /// Establece la noche activa para el usuario
  Future<void> setActiveNight(String nightId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': nightId});
    await refresh(); // Recargar datos para que activeNightId se actualice
  }

  /// Limpia la noche activa del usuario
  Future<void> clearActiveNight() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');
    await _firestore.collection('users').doc(userId).update({'activeNightId': null});
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

      final newPoints = currentPoints + pointsEarned;
      final newNights = currentNights + nightsCompletedIncrement;
      final newChallenges = currentChallenges + challengesCompletedIncrement;

      await docRef.update({
        'points': newPoints,
        'nightsCompleted': newNights,
        'challengesCompleted': newChallenges,
      });

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
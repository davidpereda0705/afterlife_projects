import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _userData = null;
        _error = 'No hay usuario autenticado';
        return;
      }
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        _userData = null;
        _error = 'Usuario no encontrado en Firestore';
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadUserData();
  }

  /// Actualiza el perfil del usuario (username, handle, y opcionalmente avatar)
  Future<void> updateUserProfile({
    required String username,
    required String handle,
    File? avatarFile,      // Si quieres subir el avatar, implementa la subida a Storage
    String? avatarUrl,     // Alternativa: pasar directamente la URL del avatar
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

    // Si tienes Firebase Storage, puedes implementar la subida aquí:
    // if (avatarFile != null) {
    //   final storageRef = FirebaseStorage.instance
    //       .ref()
    //       .child('avatars')
    //       .child('$userId.jpg');
    //   await storageRef.putFile(avatarFile);
    //   final downloadUrl = await storageRef.getDownloadURL();
    //   updateData['avatarUrl'] = downloadUrl;
    // }

    try {
      await _firestore.collection('users').doc(userId).update(updateData);
      await refresh();
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  /// Actualiza las estadísticas del usuario después de finalizar una noche.
  /// [pointsEarned] : puntos obtenidos por el usuario en la noche.
  /// [nightsCompletedIncrement] : normalmente 1.
  /// [challengesCompletedIncrement] : número de retos completados en la noche.
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
}
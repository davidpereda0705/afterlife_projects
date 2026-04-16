// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userState => _auth.authStateChanges();

  // Registro con email, contraseña y nombre de usuario
  Future<User?> registerWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Datos iniciales del usuario con todos los campos que usará la app
      final userData = {
        'username': username,
        'email': email,
        'level': 1,
        'points': 0,
        'nightsCompleted': 0,
        'challengesCompleted': 0,
        'friendsCount': 0,
        'achievementsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Guardar en Firestore (esperamos a que termine para asegurar consistencia)
      await _firestore.collection('users').doc(result.user!.uid).set(userData);
      print('✅ Usuario guardado en Firestore con datos iniciales');

      return result.user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'La contraseña es demasiado débil.';
          break;
        case 'email-already-in-use':
          message = 'El email ya está en uso.';
          break;
        case 'invalid-email':
          message = 'El email no es válido.';
          break;
        default:
          message = 'Error de autenticación: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Inicio de sesión
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado.';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta.';
          break;
        default:
          message = 'Error al iniciar sesión: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener el usuario actual (solo Authentication)
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Cambia la contraseña del usuario actual.
  /// Requiere la contraseña actual para reautenticar.
  /// Lanza una excepción si la reautenticación falla o si hay otro error.
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (newPassword.length < 6) {
      throw Exception('La nueva contraseña debe tener al menos 6 caracteres');
    }

    // Reautenticar con la contraseña actual
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Contraseña actual incorrecta');
      } else {
        throw Exception('Error al cambiar contraseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
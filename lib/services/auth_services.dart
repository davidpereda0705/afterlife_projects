// Servicio de autenticación: registro, login, logout y cambio de contraseña
// usando Firebase Auth. También crea el documento de usuario en Firestore al registrarse.
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afterlife_projects/core/app_constants.dart';

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
        AppConstants.fieldUsername: username,
        AppConstants.fieldEmail: email,
        AppConstants.fieldLevel: 1,
        AppConstants.fieldPoints: 0,
        AppConstants.fieldNightsCompleted: 0,
        AppConstants.fieldChallengesCompleted: 0,
        AppConstants.fieldFriendsCount: 0,
        'achievementsCount': 0,
        AppConstants.fieldPhotosUploaded: 0, // Añadir
        AppConstants.fieldNightsCreated: 0, // Añadir
        AppConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      };

      // Guardar en Firestore (esperamos a que termine para asegurar consistencia)
      final user = result.user;
      if (user == null) throw Exception('Error al crear el usuario');
      await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(userData);

      // Enviar email de verificación
      await user.sendEmailVerification();

      return user;
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

  // Verificar si el email está verificado
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reenviar email de verificación
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Cambia la contraseña del usuario actual.
  /// Requiere la contraseña actual para reautenticar.
  /// Lanza una excepción si la reautenticación falla o si hay otro error.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (newPassword.length < 6) {
      throw Exception('La nueva contraseña debe tener al menos 6 caracteres');
    }

    // Reautenticar con la contraseña actual
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email ?? '',
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
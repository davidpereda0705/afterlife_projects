// lib/services/auth_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userState => _auth.authStateChanges();

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

      // Guardar en Firestore de forma asíncrona (no bloquea el registro)
      _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set({
            'username': username,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .then((_) {
            print('Guardado exitoso en Firestore');
          })
          .catchError((error) {
            print('Error guardando en Firestore: $error');
          });

      return result.user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de autenticación
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

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

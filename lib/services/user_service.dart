// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/app_constants.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener stream de los datos del usuario actual (se actualiza automáticamente)
  Stream<Map<String, dynamic>?> getUserDataStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _firestore.collection(AppConstants.usersCollection).doc(uid).snapshots().map((doc) {
      if (doc.exists) return doc.data();
      return null;
    });
  }

  // Obtener datos una sola vez (Future)
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    debugPrint('UID del usuario: $uid');
    if (uid == null) return null;
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    debugPrint('Documento existe: ${doc.exists}');
    debugPrint('Datos: ${doc.data()}');
    return doc.data();
  }

  // Actualizar campos específicos del usuario (por ejemplo, después de completar una noche)
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update(updates);
  }

  // Incrementar un contador (noches, retos, puntos, etc.)
  Future<void> incrementField(String field, int incrementBy) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      field: FieldValue.increment(incrementBy),
    });
  }

  // Obtener el nombre de usuario (conveniencia)
  Future<String?> getUserName() async {
    final data = await getUserData();
    return data?[AppConstants.fieldUsername];
  }

  // Obtener el nivel actual
  Future<int?> getUserLevel() async {
    final data = await getUserData();
    return data?[AppConstants.fieldLevel];
  }

  // Obtener los puntos totales
  Future<int?> getUserPoints() async {
    final data = await getUserData();
    return data?[AppConstants.fieldPoints];
  }
}
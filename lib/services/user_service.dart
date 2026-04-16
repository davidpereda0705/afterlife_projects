// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener stream de los datos del usuario actual (se actualiza automáticamente)
  Stream<Map<String, dynamic>?> getUserDataStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) return doc.data();
      return null;
    });
  }

  // Obtener datos una sola vez (Future)
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    print('UID del usuario: $uid');
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    print('Documento existe: ${doc.exists}');
    print('Datos: ${doc.data()}');
    return doc.data();
  }

  // Actualizar campos específicos del usuario (por ejemplo, después de completar una noche)
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update(updates);
  }

  // Incrementar un contador (noches, retos, puntos, etc.)
  Future<void> incrementField(String field, int incrementBy) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      field: FieldValue.increment(incrementBy),
    });
  }

  // Obtener el nombre de usuario (conveniencia)
  Future<String?> getUserName() async {
    final data = await getUserData();
    return data?['username'];
  }

  // Obtener el nivel actual
  Future<int?> getUserLevel() async {
    final data = await getUserData();
    return data?['level'];
  }

  // Obtener los puntos totales
  Future<int?> getUserPoints() async {
    final data = await getUserData();
    return data?['points'];
  }
}

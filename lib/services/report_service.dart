import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  /// Reporta a un usuario por comportamiento inapropiado
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? details,
  }) async {
    final reporterUid = _currentUid;
    if (reporterUid == null) throw Exception('No autenticado');
    if (reporterUid == reportedUserId) throw Exception('No puedes reportarte a ti mismo');

    await _firestore.collection('reports').add({
      'reporterId': reporterUid,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'details': details ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Bloquea a un usuario
  Future<void> blockUser(String blockedUserId) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('No autenticado');
    if (uid == blockedUserId) throw Exception('No puedes bloquearte a ti mismo');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .doc(blockedUserId)
        .set({'blockedAt': FieldValue.serverTimestamp()});
  }

  /// Desbloquea a un usuario
  Future<void> unblockUser(String blockedUserId) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('No autenticado');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .doc(blockedUserId)
        .delete();
  }

  /// Verifica si un usuario está bloqueado
  Future<bool> isBlocked(String userId) async {
    final uid = _currentUid;
    if (uid == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .doc(userId)
        .get();
    return doc.exists;
  }

  /// Obtiene lista de usuarios bloqueados
  Stream<List<String>> getBlockedUsers() {
    final uid = _currentUid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_users')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }
}

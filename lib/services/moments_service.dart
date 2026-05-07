import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MomentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  /// Crea un momento efímero (24h) para una noche
  Future<void> createMoment({
    required String nightId,
    required String nightName,
    String? text,
    List<int>? imageBytes,
  }) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('No autenticado');

    String? imageUrl;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('moments/$nightId/$fileName');
      await ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imageUrl = await ref.getDownloadURL();
    }

    final now = DateTime.now();
    await _firestore.collection('moments').add({
      'nightId': nightId,
      'nightName': nightName,
      'userId': uid,
      'text': text ?? '',
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
    });
  }

  /// Obtiene momentos activos (no expirados) de una noche
  Stream<List<Map<String, dynamic>>> getActiveMoments(String nightId) {
    final now = Timestamp.now();
    return _firestore
        .collection('moments')
        .where('nightId', isEqualTo: nightId)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'userId': data['userId'],
                'text': data['text'],
                'imageUrl': data['imageUrl'],
                'createdAt': data['createdAt'],
                'expiresAt': data['expiresAt'],
              };
            }).toList());
  }

  /// Elimina momentos expirados (puede llamarse periódicamente)
  Future<void> cleanupExpiredMoments() async {
    final now = Timestamp.now();
    final batch = _firestore.batch();
    final snap = await _firestore
        .collection('moments')
        .where('expiresAt', isLessThanOrEqualTo: now)
        .limit(100)
        .get();
    for (var doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

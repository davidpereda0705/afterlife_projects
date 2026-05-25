// Servicio de chat en tiempo real dentro de una noche: envío y escucha de mensajes via Firestore streams.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NightChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  Stream<List<Map<String, dynamic>>> getMessages(String nightId) {
    return _firestore
        .collection('night_chats')
        .doc(nightId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'text': data['text'] ?? '',
                'senderId': data['senderId'] ?? '',
                'senderName': data['senderName'] ?? 'Usuario',
                'timestamp': data['timestamp'],
                'isMe': data['senderId'] == _currentUid,
              };
            }).toList());
  }

  Future<void> sendMessage(String nightId, String text, String senderName) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('No autenticado');
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > 500) throw Exception('Máximo 500 caracteres');

    await _firestore
        .collection('night_chats')
        .doc(nightId)
        .collection('messages')
        .add({
      'text': trimmed,
      'senderId': uid,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

// Chat entre amigos: enviar mensajes, escuchar mensajes en tiempo real
// y gestionar conversaciones privadas entre dos usuarios.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Obtener o crear un chat con otro usuario
  Future<String> getOrCreateChat(String otherUserId, String otherUserName) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final chatId = _getChatId(uid, otherUserId);
    
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();
    
    if (!chatDoc.exists) {
      // Obtener nombre del usuario actual
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      final currentUserName = currentUserDoc.data()?['username'] ?? 'Usuario';
      
      await chatRef.set({
        'participants': [uid, otherUserId],
        'participantNames': {
          uid: currentUserName,
          otherUserId: otherUserName,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Crear subcolección de mensajes
      await chatRef.collection('messages').doc('placeholder').set({
        'text': 'Chat creado',
        'senderId': 'system',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    
    return chatId;
  }

  // Enviar mensaje
  Future<void> sendMessage(String chatId, String text) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > 500) throw Exception('El mensaje no puede superar los 500 caracteres');
    
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    
    await messageRef.set({
      'text': trimmed,
      'senderId': uid,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'deleted': false,
    });
    
    // Actualizar último mensaje en el chat
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    
    // Incrementar contador de no leídos para el otro usuario
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
    final otherUserId = participants.firstWhere((id) => id != uid);

    await _firestore.collection('users').doc(otherUserId).collection('chats').doc(chatId).set({
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatId) async {
    final uid = currentUserId;
    if (uid == null) return;
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      if (doc.data()['senderId'] != uid) {
        batch.update(doc.reference, {'read': true});
      }
    }
    await batch.commit();

    // Resetear contador de no leídos
    await _firestore.collection('users').doc(uid).collection('chats').doc(chatId).set({
      'unreadCount': 0,
    }, SetOptions(merge: true));
  }

  // Establecer estado "escribiendo"
  void setTyping(String chatId, bool isTyping) {
    final uid = currentUserId;
    if (uid == null) return;
    _firestore
        .collection('users')
        .doc(uid)
        .collection('typing')
        .doc(chatId)
        .set({'isTyping': isTyping});
  }

  // Escuchar si el otro usuario está escribiendo
  Stream<bool> getTypingStatus(String chatId, String otherUserId) {
    return _firestore
        .collection('users')
        .doc(otherUserId)
        .collection('typing')
        .doc(chatId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['isTyping'] ?? false);
  }

  // Stream de mensajes de un chat
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    final uid = currentUserId;
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'text': doc.data()['text'] ?? '',
                'senderId': doc.data()['senderId'] ?? '',
                'timestamp': doc.data()['timestamp'],
                'read': doc.data()['read'] ?? false,
                'deleted': doc.data()['deleted'] ?? false,
                'isMe': doc.data()['senderId'] == uid,
              })
          .where((msg) => msg['deleted'] == false)
          .toList();

      // Ordenar por timestamp (descendente) en Dart
      messages.sort((a, b) {
        final t1 = a['timestamp'] as Timestamp?;
        final t2 = b['timestamp'] as Timestamp?;
        if (t1 == null) return -1; // Los nuevos arriba
        if (t2 == null) return 1;
        return t2.compareTo(t1);
      });

      return messages;
    });
  }

  // Buscar mensajes en un chat
  Future<List<Map<String, dynamic>>> searchMessages(String chatId, String query) async {
    if (query.isEmpty) return [];

    // Por qué no usamos orderBy('timestamp') aquí en la query:
    //   Firestore no permite combinar un range filter (.where('text', isGreaterThanOrEqualTo: ...))
    //   con un orderBy de un campo DISTINTO ('timestamp') sin un índice compuesto en la consola.
    //   Para evitar esa dependencia de configuración, filtramos en Firestore y ordenamos en Dart.
    final results = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('text', isGreaterThanOrEqualTo: query)
        .where('text', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(100)
        .get();

    final messages = results.docs
        .where((doc) => doc.data()['deleted'] != true && doc.data()['senderId'] != 'system')
        .map((doc) {
          return {
            'id': doc.id,
            'text': doc.data()['text'],
            'senderId': doc.data()['senderId'],
            'timestamp': doc.data()['timestamp'],
          };
        })
        .toList();

    // Ordenar por timestamp descendente en Dart
    messages.sort((a, b) {
      final t1 = a['timestamp'] as Timestamp?;
      final t2 = b['timestamp'] as Timestamp?;
      if (t1 == null && t2 == null) return 0;
      if (t1 == null) return 1;
      if (t2 == null) return -1;
      return t2.compareTo(t1);
    });

    // Limitar a 50 después de ordenar
    if (messages.length > 50) return messages.sublist(0, 50);
    return messages;
  }

  // "Soft delete" (borrado lógico): marcamos el mensaje como eliminado en lugar de borrarlo.
  // Razón: si borrásemos el documento, el otro usuario vería el chat roto o con huecos.
  // Al marcar 'deleted: true' y filtrarlo en el stream, el mensaje simplemente desaparece
  // visualmente pero el historial de Firestore permanece intacto y ordenado.
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'deleted': true});
  }

  // Obtener lista de chats del usuario (con último mensaje y no leídos)
  Stream<List<Map<String, dynamic>>> getUserChats() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final chats = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants']);
            final otherUserId = participants.firstWhere((id) => id != uid);

            final userDoc = await _firestore.collection('users').doc(otherUserId).get();
            final otherUserName = userDoc.data()?['username'] ?? 'Usuario';
            final otherUserInitials = _getInitials(otherUserName);

            // Obtener contador de no leídos
            final unreadDoc = await _firestore
                .collection('users')
                .doc(uid)
                .collection('chats')
                .doc(doc.id)
                .get();
            final unreadCount = unreadDoc.data()?['unreadCount'] ?? 0;

            chats.add({
              'chatId': doc.id,
              'otherUserId': otherUserId,
              'otherUserName': otherUserName,
              'otherUserInitials': otherUserInitials,
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime': data['lastMessageTime'],
              'unreadCount': unreadCount,
            });
          }
          return chats;
        });
  }

  // Genera siempre el mismo ID para el mismo par de usuarios, sin importar el orden.
  // Al ordenar los UIDs alfabéticamente, 'A_B' y 'B_A' producen el mismo ID.
  // Esto evita crear dos documentos de chat duplicados para la misma conversación.
  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
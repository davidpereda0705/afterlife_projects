// lib/services/friend_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // Obtener el nombre del usuario actual
  Future<String> getCurrentUserName() async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    return doc.data()?['username'] ?? 'Usuario';
  }

  // Buscar usuarios por nombre
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final results = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(20)
        .get();
    
    return results.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) => ({
              'uid': doc.id,
              'name': doc.data()['username'] ?? 'Sin nombre',
              'email': doc.data()['email'] ?? '',
              'initials': _getInitials(doc.data()['username'] ?? ''),
            }))
        .toList();
  }

  // Enviar solicitud de amistad
  Future<void> sendFriendRequest(String friendUid) async {
    final batch = _firestore.batch();
    
    final myRequestRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(friendUid);
    
    batch.set(myRequestRef, {
      'uid': friendUid,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
    
    final friendRequestRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friend_requests')
        .doc(currentUserId);
    
    batch.set(friendRequestRef, {
      'uid': currentUserId,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }

  // Aceptar solicitud
  Future<void> acceptFriendRequest(String friendUid) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    
    final myFriendRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendUid);
    
    batch.set(myFriendRef, {
      'uid': friendUid,
      'status': 'accepted',
      'since': now,
    });
    
    final friendFriendRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(currentUserId);
    
    batch.set(friendFriendRef, {
      'uid': currentUserId,
      'status': 'accepted',
      'since': now,
    });
    
    final myRequestRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(friendUid);
    
    batch.delete(myRequestRef);
    
    final friendRequestRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friend_requests')
        .doc(currentUserId);
    
    batch.delete(friendRequestRef);
    
    await batch.commit();
  }

  // Rechazar solicitud
  Future<void> rejectFriendRequest(String friendUid) async {
    final batch = _firestore.batch();
    
    final myRequestRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(friendUid);
    
    batch.delete(myRequestRef);
    
    final friendRequestRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friend_requests')
        .doc(currentUserId);
    
    batch.delete(friendRequestRef);
    
    await batch.commit();
  }

  // Obtener amigos (aceptados)
  Stream<List<Map<String, dynamic>>> getFriends() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
          final friends = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final friendUid = doc.id;
            final userDoc = await _firestore.collection('users').doc(friendUid).get();
            friends.add({
              'uid': friendUid,
              'name': userDoc.data()?['username'] ?? 'Sin nombre',
              'email': userDoc.data()?['email'] ?? '',
              'initials': _getInitials(userDoc.data()?['username'] ?? ''),
              'status': 'online',
              'message': '¡Conectado!',
              'time': _formatTime(doc.data()['since']),
              'unread': 0,
              'typing': false,
            });
          }
          return friends;
        });
  }

  // Obtener solicitudes pendientes
  Stream<List<Map<String, dynamic>>> getFriendRequests() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          final requests = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final requesterUid = doc.id;
            final userDoc = await _firestore.collection('users').doc(requesterUid).get();
            requests.add({
              'uid': requesterUid,
              'name': userDoc.data()?['username'] ?? 'Sin nombre',
              'email': userDoc.data()?['email'] ?? '',
              'initials': _getInitials(userDoc.data()?['username'] ?? ''),
            });
          }
          return requests;
        });
  }

  // Eliminar amigo
  Future<void> removeFriend(String friendUid) async {
    final batch = _firestore.batch();
    
    final myFriendRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendUid);
    
    batch.delete(myFriendRef);
    
    final friendFriendRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(currentUserId);
    
    batch.delete(friendFriendRef);
    
    await batch.commit();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'reciente';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return 'hace ${diff.inDays} día(s)';
    if (diff.inHours > 0) return 'hace ${diff.inHours} hora(s)';
    if (diff.inMinutes > 0) return 'hace ${diff.inMinutes} min';
    return 'ahora';
  }
}
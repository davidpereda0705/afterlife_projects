// Gestión de amigos: enviar/aceptar/rechazar solicitudes de amistad,
// listar amigos, y eliminar amistades existentes.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afterlife_projects/core/app_constants.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Obtener el nombre del usuario actual
  Future<String> getCurrentUserName() async {
    final uid = currentUserId;
    if (uid == null) return 'Usuario';
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    return doc.data()?[AppConstants.fieldUsername] ?? 'Usuario';
  }

  // Buscar usuarios por nombre (b\u00fasqueda de prefijo)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final uid = currentUserId;
    if (uid == null) return [];

    // Firestore no tiene b\u00fasqueda de texto completo nativa.
    // Este truco de rango ("query" a "query\uf8ff") simula un "STARTS WITH":
    // \uf8ff es el car\u00e1cter Unicode m\u00e1s alto en el rango de caracteres privados,
    // por lo que 'query\uf8ff' es mayor que cualquier string que empiece por 'query'.
    // Resultado: devuelve todos los documentos cuyo username empieza por 'query'.
    final results = await _firestore
        .collection(AppConstants.usersCollection)
        .where(AppConstants.fieldUsername, isGreaterThanOrEqualTo: query)
        .where(AppConstants.fieldUsername, isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return results.docs
        .where((doc) => doc.id != uid)
        .map((doc) => ({
              'uid': doc.id,
              AppConstants.fieldNightName: doc.data()[AppConstants.fieldUsername] ?? 'Sin nombre',
              // NO exponemos el email de otros usuarios por privacidad
              'initials': _getInitials(doc.data()[AppConstants.fieldUsername] ?? ''),
            }))
        .toList();
  }

  // Enviar solicitud de amistad
  Future<void> sendFriendRequest(String friendUid) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final batch = _firestore.batch();
    
    final myRequestRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friend_requests')
        .doc(friendUid);

    batch.set(myRequestRef, {
      'uid': friendUid,
      AppConstants.fieldStatus: 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    final friendRequestRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(friendUid)
        .collection('friend_requests')
        .doc(uid);

    batch.set(friendRequestRef, {
      'uid': uid,
      AppConstants.fieldStatus: 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }

  // Aceptar solicitud (con incremento de friendsCount)
  Future<void> acceptFriendRequest(String friendUid) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    
    // Añadir a subcolección friends de cada usuario
    final myFriendRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friends')
        .doc(friendUid);
    batch.set(myFriendRef, {
      'uid': friendUid,
      AppConstants.fieldStatus: 'accepted',
      'since': now,
    });

    final friendFriendRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(friendUid)
        .collection('friends')
        .doc(uid);
    batch.set(friendFriendRef, {
      'uid': uid,
      AppConstants.fieldStatus: 'accepted',
      'since': now,
    });
    
    // Eliminar solicitudes pendientes
    final myRequestRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friend_requests')
        .doc(friendUid);
    batch.delete(myRequestRef);

    final friendRequestRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(friendUid)
        .collection('friend_requests')
        .doc(uid);
    batch.delete(friendRequestRef);

    // Incrementar friendsCount en los documentos de usuario
    batch.update(_firestore.collection(AppConstants.usersCollection).doc(uid), {
      AppConstants.fieldFriendsCount: FieldValue.increment(1),
    });
    batch.update(_firestore.collection(AppConstants.usersCollection).doc(friendUid), {
      AppConstants.fieldFriendsCount: FieldValue.increment(1),
    });
    
    await batch.commit();
  }

  // Rechazar solicitud
  Future<void> rejectFriendRequest(String friendUid) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final batch = _firestore.batch();

    final myRequestRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friend_requests')
        .doc(friendUid);
    batch.delete(myRequestRef);

    final friendRequestRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(friendUid)
        .collection('friend_requests')
        .doc(uid);
    batch.delete(friendRequestRef);

    await batch.commit();
  }

  // Obtener amigos (aceptados)
  Stream<List<Map<String, dynamic>>> getFriends() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friends')
        .where(AppConstants.fieldStatus, isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
          final friends = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final friendUid = doc.id;
            final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(friendUid).get();
            friends.add({
              'uid': friendUid,
              AppConstants.fieldNightName: userDoc.data()?[AppConstants.fieldUsername] ?? 'Sin nombre',
              // NO exponemos el email de otros usuarios por privacidad
              'initials': _getInitials(userDoc.data()?[AppConstants.fieldUsername] ?? ''),
              AppConstants.fieldStatus: 'online',   // Puedes mejorar esto con presencia real
              'message': '¡Conectado!',
              AppConstants.fieldTime: _formatTime(doc.data()['since']),
              'unread': 0,
              'typing': false,
            });
          }
          return friends;
        });
  }

  // Obtener solicitudes pendientes
  Stream<List<Map<String, dynamic>>> getFriendRequests() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friend_requests')
        .where(AppConstants.fieldStatus, isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          final requests = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final requesterUid = doc.id;
            final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(requesterUid).get();
            requests.add({
              'uid': requesterUid,
              AppConstants.fieldNightName: userDoc.data()?[AppConstants.fieldUsername] ?? 'Sin nombre',
              // NO exponemos el email de otros usuarios por privacidad
              'initials': _getInitials(userDoc.data()?[AppConstants.fieldUsername] ?? ''),
            });
          }
          return requests;
        });
  }

  // Eliminar amigo (con decremento de friendsCount)
  Future<void> removeFriend(String friendUid) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final batch = _firestore.batch();

    final myFriendRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('friends')
        .doc(friendUid);
    batch.delete(myFriendRef);

    final friendFriendRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(friendUid)
        .collection('friends')
        .doc(uid);
    batch.delete(friendFriendRef);

    // Decrementar friendsCount
    batch.update(_firestore.collection(AppConstants.usersCollection).doc(uid), {
      AppConstants.fieldFriendsCount: FieldValue.increment(-1),
    });
    batch.update(_firestore.collection(AppConstants.usersCollection).doc(friendUid), {
      AppConstants.fieldFriendsCount: FieldValue.increment(-1),
    });

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
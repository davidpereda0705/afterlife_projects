// lib/services/night_service.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear una nueva noche
  Future<String> createNight({
    required String name,
    required String hostId,
    required String hostName,
    required String hostInitials,
    required String groupName,
    required String day,
    required String time,
    required int maxPlayers,
    required List<Map<String, dynamic>> challenges,
  }) async {
    final nightRef = _firestore.collection('nights').doc();
    final nightData = {
      'id': nightRef.id,
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'hostInitials': hostInitials,
      'groupName': groupName,
      'day': day,
      'time': time,
      'maxPlayers': maxPlayers,
      'status': 'waiting', // waiting, in_progress, finished
      'players': [
        {
          'userId': hostId,
          'name': hostName,
          'initials': hostInitials,
          'points': 0,
        },
      ],
      'challenges': challenges.map((c) {
        return {
          'name': c['name'],
          'points': c['points'],
          'completed': false,
          'completedBy': null,
          'proofBytes':
              null, // Guardaremos los bytes aquí (no recomendado para producción)
        };
      }).toList(),
      'nightPhotos':
          [], // Lista de strings (URLs) o bytes. Usaremos bytes por ahora.
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': null,
      'finishedAt': null,
    };
    await nightRef.set(nightData);
    return nightRef.id;
  }

  // Obtener noches disponibles (status waiting y no llenas)
  Future<List<Map<String, dynamic>>> getAvailableNights() async {
    final snapshot = await _firestore
        .collection('nights')
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt', descending: true)
        .get();
    final nights = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final players = data['players'] as List? ?? [];
      final maxPlayers = data['maxPlayers'] ?? 0;
      if (players.length < maxPlayers) {
        nights.add(data);
      }
    }
    return nights;
  }

  // Obtener una noche por ID
  Future<Map<String, dynamic>?> getNightById(String nightId) async {
    final doc = await _firestore.collection('nights').doc(nightId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Stream en tiempo real de una noche
  Stream<Map<String, dynamic>?> streamNight(String nightId) {
    return _firestore
        .collection('nights')
        .doc(nightId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  // Unirse a una noche
  Future<void> joinNight(
    String nightId,
    String userId,
    String username,
    String initials,
  ) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(nightRef);
      if (!snapshot.exists) throw Exception('La noche no existe');
      final data = snapshot.data()!;
      final players = List<Map<String, dynamic>>.from(data['players'] ?? []);
      final maxPlayers = data['maxPlayers'] ?? 0;
      if (players.length >= maxPlayers) throw Exception('La noche está llena');
      // Verificar si ya está unido
      if (players.any((p) => p['userId'] == userId))
        throw Exception('Ya estás en esta noche');
      players.add({
        'userId': userId,
        'name': username,
        'initials': initials,
        'points': 0,
      });
      transaction.update(nightRef, {'players': players});
    });
  }

  // Completar un reto (con imagen de prueba opcional)
  Future<void> completeChallenge(
    String nightId,
    int challengeIndex,
    String playerName,
    Uint8List? proofBytes,
  ) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(nightRef);
      if (!snapshot.exists) throw Exception('La noche no existe');
      final data = snapshot.data()!;
      final challenges = List<Map<String, dynamic>>.from(data['challenges']);
      if (challengeIndex >= challenges.length)
        throw Exception('Reto no existe');
      final challenge = challenges[challengeIndex];
      if (challenge['completed'] == true) throw Exception('Reto ya completado');

      // Marcar reto como completado
      challenge['completed'] = true;
      challenge['completedBy'] = playerName;
      if (proofBytes != null) {
        // Guardar bytes de la imagen (no recomendado para producción, pero por ahora)
        challenge['proofBytes'] = proofBytes;
      }
      challenges[challengeIndex] = challenge;

      // Sumar puntos al jugador
      final points = challenge['points'] as int? ?? 0;
      final players = List<Map<String, dynamic>>.from(data['players']);
      bool playerFound = false;
      for (int i = 0; i < players.length; i++) {
        if (players[i]['name'] == playerName) {
          players[i]['points'] = (players[i]['points'] ?? 0) + points;
          playerFound = true;
          break;
        }
      }
      if (!playerFound) throw Exception('Jugador no encontrado');

      transaction.update(nightRef, {
        'challenges': challenges,
        'players': players,
      });
    });
  }

  // Finalizar la noche (cambiar estado a finished)
  Future<void> finishNight(String nightId) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await nightRef.update({
      'status': 'finished',
      'finishedAt': FieldValue.serverTimestamp(),
    });
  }

  // Agregar foto a la noche (como bytes)
  Future<void> addNightPhoto(String nightId, Uint8List imageBytes) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await nightRef.update({
      'nightPhotos': FieldValue.arrayUnion([imageBytes]),
    });
  }
}

// lib/services/night_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class NightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  // NIGHTS CRUD
  // --------------------------------------------------------------------------

  /// Crea una nueva noche en Firestore y devuelve su ID.
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
    final nightData = {
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
        }
      ],
      'challenges': challenges.map((c) {
        return {
          'name': c['name'],
          'points': c['points'],
          'completed': false,
          'completedBy': null,
          'proofBytes': null, // Uint8List se guardará como array de números
        };
      }).toList(),
      'nightPhotos': [], // Lista de Uint8List (se guardará como array de arrays)
      'createdAt': FieldValue.serverTimestamp(),
    };
    final docRef = await _firestore.collection('nights').add(nightData);
    return docRef.id;
  }

  /// Obtiene todas las noches disponibles (status == 'waiting' y no llenas)
  Future<List<Map<String, dynamic>>> getAvailableNights() async {
    final snapshot = await _firestore
        .collection('nights')
        .where('status', isEqualTo: 'waiting')
        .get();
    final nights = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final players = data['players'] as List? ?? [];
      final maxPlayers = data['maxPlayers'] ?? 0;
      if (players.length < maxPlayers) {
        nights.add({...data, 'id': doc.id});
      }
    }
    return nights;
  }

  /// Obtiene una noche por su ID
  Future<Map<String, dynamic>?> getNightById(String nightId) async {
    final doc = await _firestore.collection('nights').doc(nightId).get();
    if (!doc.exists) return null;
    return {...doc.data()!, 'id': doc.id};
  }

  /// Escucha cambios en tiempo real de una noche
  Stream<Map<String, dynamic>?> streamNight(String nightId) {
    return _firestore
        .collection('nights')
        .doc(nightId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return {...snapshot.data()!, 'id': snapshot.id};
    });
  }

  // --------------------------------------------------------------------------
  // JOIN NIGHT
  // --------------------------------------------------------------------------

  /// Añade un jugador a la noche (actualiza el array players)
  Future<void> joinNight(String nightId, String userId, String userName, String userInitials) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(nightRef);
      if (!doc.exists) throw Exception('La noche no existe');
      final players = List<Map<String, dynamic>>.from(doc.data()?['players'] ?? []);
      if (players.any((p) => p['userId'] == userId)) {
        throw Exception('El usuario ya está en la noche');
      }
      final maxPlayers = doc.data()?['maxPlayers'] ?? 0;
      if (players.length >= maxPlayers) {
        throw Exception('La noche está llena');
      }
      players.add({
        'userId': userId,
        'name': userName,
        'initials': userInitials,
        'points': 0,
      });
      transaction.update(nightRef, {'players': players});
    });
  }

  // --------------------------------------------------------------------------
  // COMPLETE CHALLENGE
  // --------------------------------------------------------------------------

  /// Marca un reto como completado, suma puntos al jugador y guarda la prueba (bytes)
  Future<void> completeChallenge(String nightId, int challengeIndex, String playerName, Uint8List? proofBytes) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(nightRef);
      if (!doc.exists) throw Exception('La noche no existe');

      final challenges = List<Map<String, dynamic>>.from(doc.data()?['challenges'] ?? []);
      if (challengeIndex >= challenges.length) throw Exception('Reto inválido');
      if (challenges[challengeIndex]['completed'] == true) throw Exception('Reto ya completado');

      // Marcar reto como completado
      challenges[challengeIndex]['completed'] = true;
      challenges[challengeIndex]['completedBy'] = playerName;
      if (proofBytes != null) {
        challenges[challengeIndex]['proofBytes'] = proofBytes.toList(); // Convertir a List<int>
      }

      // Sumar puntos al jugador
      final players = List<Map<String, dynamic>>.from(doc.data()?['players'] ?? []);
      final pointsToAdd = challenges[challengeIndex]['points'] as int;
      bool playerFound = false;
      for (var player in players) {
        if (player['name'] == playerName) {
          player['points'] = (player['points'] ?? 0) + pointsToAdd;
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

  // --------------------------------------------------------------------------
  // NIGHT PHOTOS
  // --------------------------------------------------------------------------

  /// Añade una foto a la noche (en bytes)
  Future<void> addNightPhoto(String nightId, Uint8List photoBytes) async {
    final nightRef = _firestore.collection('nights').doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(nightRef);
      if (!doc.exists) throw Exception('La noche no existe');
      final nightPhotos = List<dynamic>.from(doc.data()?['nightPhotos'] ?? []);
      nightPhotos.add(photoBytes.toList()); // Convertir a List<int>
      transaction.update(nightRef, {'nightPhotos': nightPhotos});
    });
  }

  // --------------------------------------------------------------------------
  // FINISH NIGHT
  // --------------------------------------------------------------------------

  /// Marca la noche como finalizada (status = 'finished')
  Future<void> finishNight(String nightId) async {
    await _firestore.collection('nights').doc(nightId).update({'status': 'finished'});
  }

  // --------------------------------------------------------------------------
  // USER ACTIVE NIGHT MANAGEMENT
  // --------------------------------------------------------------------------

  /// Establece la noche activa para un usuario
  Future<void> setActiveNightForUser(String userId, String nightId) async {
    await _firestore.collection('users').doc(userId).update({
      'activeNightId': nightId,
    });
  }

  /// Limpia la noche activa del usuario
  Future<void> clearActiveNightForUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'activeNightId': null,
    });
  }
}
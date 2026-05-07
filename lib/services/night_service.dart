import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

import '../core/enums.dart';
import '../core/app_constants.dart';

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
      AppConstants.fieldNightName: name,
      AppConstants.fieldHostId: hostId,
      AppConstants.fieldHostName: hostName,
      AppConstants.fieldHostInitials: hostInitials,
      AppConstants.fieldGroupName: groupName,
      AppConstants.fieldDay: day,
      AppConstants.fieldTime: time,
      AppConstants.fieldMaxPlayers: maxPlayers,
      AppConstants.fieldStatus: NightStatus.waiting.value,
      AppConstants.fieldPlayers: [
        {
          'userId': hostId,
          AppConstants.fieldNightName: hostName,
          'initials': hostInitials,
          AppConstants.fieldPoints: 0,
        }
      ],
      AppConstants.fieldChallenges: challenges.map((c) {
        return {
          AppConstants.fieldNightName: c[AppConstants.fieldNightName],
          AppConstants.fieldPoints: c[AppConstants.fieldPoints],
          'completed': false,
          'completedBy': null,
          'proofBytes': null,
        };
      }).toList(),
      AppConstants.fieldNightPhotos: [],
      AppConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
    };
    final docRef = await _firestore.collection(AppConstants.nightsCollection).add(nightData);
    return docRef.id;
  }

  /// Obtiene todas las noches disponibles (status == 'waiting' y no llenas)
  Future<List<Map<String, dynamic>>> getAvailableNights() async {
    final snapshot = await _firestore
        .collection(AppConstants.nightsCollection)
        .where(AppConstants.fieldStatus, isEqualTo: NightStatus.waiting.value)
        .get();
    final nights = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final players = data[AppConstants.fieldPlayers] as List? ?? [];
      final maxPlayers = data[AppConstants.fieldMaxPlayers] ?? 0;
      if (players.length < maxPlayers) {
        nights.add({...data, 'id': doc.id});
      }
    }
    return nights;
  }

  /// Obtiene una noche por su ID
  Future<Map<String, dynamic>?> getNightById(String nightId) async {
    final doc = await _firestore.collection(AppConstants.nightsCollection).doc(nightId).get();
    if (!doc.exists) return null;
    return {...doc.data()!, 'id': doc.id};
  }

  /// Escucha cambios en tiempo real de una noche
  Stream<Map<String, dynamic>?> streamNight(String nightId) {
    return _firestore
        .collection(AppConstants.nightsCollection)
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
    final nightRef = _firestore.collection(AppConstants.nightsCollection).doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(nightRef);
      if (!doc.exists) throw Exception('La noche no existe');
      final players = List<Map<String, dynamic>>.from(doc.data()?[AppConstants.fieldPlayers] ?? []);
      if (players.any((p) => p['userId'] == userId)) {
        throw Exception('El usuario ya está en la noche');
      }
      final maxPlayers = doc.data()?[AppConstants.fieldMaxPlayers] ?? 0;
      if (players.length >= maxPlayers) {
        throw Exception('La noche está llena');
      }
      players.add({
        'userId': userId,
        AppConstants.fieldNightName: userName,
        'initials': userInitials,
        AppConstants.fieldPoints: 0,
      });
      transaction.update(nightRef, {AppConstants.fieldPlayers: players});
    });
  }

  // --------------------------------------------------------------------------
  // COMPLETE CHALLENGE
  // --------------------------------------------------------------------------

  /// Marca un reto como completado, suma puntos al jugador y guarda la prueba (bytes)
  Future<void> completeChallenge(String nightId, int challengeIndex, String playerName, Uint8List? proofBytes) async {
    final nightRef = _firestore.collection(AppConstants.nightsCollection).doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(nightRef);
      if (!doc.exists) throw Exception('La noche no existe');

      final challenges = List<Map<String, dynamic>>.from(doc.data()?[AppConstants.fieldChallenges] ?? []);
      if (challengeIndex >= challenges.length) throw Exception('Reto inválido');
      if (challenges[challengeIndex]['completed'] == true) throw Exception('Reto ya completado');

      // Marcar reto como completado
      challenges[challengeIndex]['completed'] = true;
      challenges[challengeIndex]['completedBy'] = playerName;
      if (proofBytes != null) {
        const maxBytes = 300 * 1024; // 300KB
        if (proofBytes.length > maxBytes) {
          throw Exception('La foto de prueba es demasiado grande (máx 300KB).');
        }
        challenges[challengeIndex]['proofBytes'] = proofBytes.toList();
      }

      // Sumar puntos al jugador
      final players = List<Map<String, dynamic>>.from(doc.data()?[AppConstants.fieldPlayers] ?? []);
      final pointsToAdd = challenges[challengeIndex][AppConstants.fieldPoints] as int;
      bool playerFound = false;
      for (var player in players) {
        if (player[AppConstants.fieldNightName] == playerName) {
          player[AppConstants.fieldPoints] = (player[AppConstants.fieldPoints] ?? 0) + pointsToAdd;
          playerFound = true;
          break;
        }
      }
      if (!playerFound) throw Exception('Jugador no encontrado');

      transaction.update(nightRef, {
        AppConstants.fieldChallenges: challenges,
        AppConstants.fieldPlayers: players,
      });
    });
  }

  // --------------------------------------------------------------------------
  // NIGHT PHOTOS (ahora guarda bytes directamente en Firestore)
  // --------------------------------------------------------------------------

  /// Añade una foto a la noche (en bytes). Los bytes se guardan en el array nightPhotos.
  Future<void> addNightPhoto(String nightId, Uint8List photoBytes) async {
    final bytesList = photoBytes.toList(); // Convertimos a List<int> para Firestore
    await _firestore
        .collection(AppConstants.nightsCollection)
        .doc(nightId)
        .update({
          AppConstants.fieldNightPhotos: FieldValue.arrayUnion([bytesList])
        });
  }

  // --------------------------------------------------------------------------
  // FINISH NIGHT
  // --------------------------------------------------------------------------

  /// Marca la noche como finalizada
  Future<void> finishNight(String nightId) async {
    await _firestore.collection(AppConstants.nightsCollection).doc(nightId).update({AppConstants.fieldStatus: NightStatus.finished.value});
  }

  // --------------------------------------------------------------------------
  // DESIGNATED DRIVER
  // --------------------------------------------------------------------------

  Future<void> toggleDesignatedDriver(String nightId, String userId, bool isDriver) async {
    final nightRef = _firestore.collection(AppConstants.nightsCollection).doc(nightId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(nightRef);
      if (!doc.exists) throw Exception('La noche no existe');
      final players = List<Map<String, dynamic>>.from(doc.data()?[AppConstants.fieldPlayers] ?? []);
      for (var p in players) {
        if ((p['userId'] ?? '') == userId) {
          p['isDesignatedDriver'] = isDriver;
          break;
        }
      }
      transaction.update(nightRef, {AppConstants.fieldPlayers: players});
    });
  }

  // --------------------------------------------------------------------------
  // EXPENSES
  // --------------------------------------------------------------------------

  Future<void> updateExpenses(String nightId, List<Map<String, dynamic>> expenses) async {
    await _firestore.collection(AppConstants.nightsCollection).doc(nightId).update({
      'expenses': expenses,
    });
  }

  Stream<List<Map<String, dynamic>>> streamExpenses(String nightId) {
    return _firestore
        .collection(AppConstants.nightsCollection)
        .doc(nightId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return [];
      return List<Map<String, dynamic>>.from(data['expenses'] ?? []);
    });
  }

  Future<void> updateSpotifyUrl(String nightId, String? url) async {
    await _firestore.collection(AppConstants.nightsCollection).doc(nightId).update({
      'spotifyUrl': url,
    });
  }

  // --------------------------------------------------------------------------
  // USER ACTIVE NIGHT MANAGEMENT
  // --------------------------------------------------------------------------

  /// Establece la noche activa para un usuario
  Future<void> setActiveNightForUser(String userId, String nightId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      AppConstants.fieldActiveNightId: nightId,
    });
  }

  /// Limpia la noche activa del usuario
  Future<void> clearActiveNightForUser(String userId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      AppConstants.fieldActiveNightId: null,
    });
  }
}
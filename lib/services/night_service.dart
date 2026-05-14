import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../core/enums.dart';
import '../core/app_constants.dart';

class NightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  // NIGHTS CRUD
  // --------------------------------------------------------------------------

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

  Future<Map<String, dynamic>?> getNightById(String nightId) async {
    final doc = await _firestore.collection(AppConstants.nightsCollection).doc(nightId).get();
    if (!doc.exists) return null;
    return {...doc.data()!, 'id': doc.id};
  }

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
  // COMPLETE CHALLENGE (sin transacción, límite de 150KB)
  // --------------------------------------------------------------------------
  Future<void> completeChallenge(String nightId, int challengeIndex, String playerName, Uint8List? proofBytes) async {
    const maxRetries = 3;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final nightRef = _firestore.collection(AppConstants.nightsCollection).doc(nightId);
        final doc = await nightRef.get();
        if (!doc.exists) throw Exception('La noche no existe');

        final challenges = List<Map<String, dynamic>>.from(doc.data()?[AppConstants.fieldChallenges] ?? []);
        if (challengeIndex >= challenges.length) throw Exception('Reto inválido');
        if (challenges[challengeIndex]['completed'] == true) throw Exception('Reto ya completado');

        // Normalizar proofBytes existentes: List<dynamic> → Uint8List (blob)
        // Si no se hace, Firestore detecta arrays anidados al reescribir el campo
        for (final c in challenges) {
          final pb = c['proofBytes'];
          if (pb != null && pb is! Uint8List) {
            try {
              c['proofBytes'] = Uint8List.fromList((pb as List).cast<int>());
            } catch (_) {
              c['proofBytes'] = null;
            }
          }
        }

        challenges[challengeIndex]['completed'] = true;
        challenges[challengeIndex]['completedBy'] = playerName;
        if (proofBytes != null) {
          if (proofBytes.length > 150 * 1024) {
            throw Exception('La imagen es demasiado grande (máx 150KB)');
          }
          challenges[challengeIndex]['proofBytes'] = proofBytes;
        }

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

        await nightRef.update({
          AppConstants.fieldChallenges: challenges,
          AppConstants.fieldPlayers: players,
        });
        return;
      } catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
  }

  // --------------------------------------------------------------------------
  // NIGHT PHOTOS – máximo 3 fotos
  // Formato: [{'data': Uint8List}, ...] — blob como campo de mapa, nunca en array directo
  // --------------------------------------------------------------------------
  Future<void> addNightPhoto(String nightId, Uint8List photoBytes) async {
    if (photoBytes.length > 150 * 1024) {
      throw Exception('La imagen es demasiado grande (máx 150KB). Elige una imagen más pequeña.');
    }
    final nightRef = _firestore.collection(AppConstants.nightsCollection).doc(nightId);
    final doc = await nightRef.get();
    final rawPhotos = doc.data()?[AppConstants.fieldNightPhotos] as List? ?? [];

    // Migrar fotos existentes al formato {'data': Uint8List}
    // Los formatos antiguos tenían {'bytes': List<int>} que causaba arrays anidados
    final normalizedPhotos = rawPhotos.map<Map<String, dynamic>?>((p) {
      if (p is Map) {
        final raw = p['data'] ?? p['bytes'];
        if (raw == null) return null;
        final bytes = raw is Uint8List
            ? raw
            : Uint8List.fromList((raw as List).cast<int>());
        return {'data': bytes};
      }
      if (p is Uint8List) return {'data': p};
      if (p is List) return {'data': Uint8List.fromList(p.cast<int>())};
      return null;
    }).whereType<Map<String, dynamic>>().toList();

    if (normalizedPhotos.length >= 3) {
      throw Exception('Máximo 3 fotos por noche. Elimina alguna antes de añadir otra.');
    }
    normalizedPhotos.add({'data': photoBytes});
    await nightRef.update({AppConstants.fieldNightPhotos: normalizedPhotos});
  }

  // --------------------------------------------------------------------------
  // FINISH NIGHT
  // --------------------------------------------------------------------------
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
  Future<void> setActiveNightForUser(String userId, String nightId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      AppConstants.fieldActiveNightId: nightId,
    });
  }

  Future<void> clearActiveNightForUser(String userId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      AppConstants.fieldActiveNightId: null,
    });
  }
}
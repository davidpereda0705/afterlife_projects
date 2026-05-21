// lib/providers/night_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:afterlife_projects/services/night_service.dart';

class NightProvider extends ChangeNotifier {
  final NightService _nightService = NightService();
  
  Map<String, dynamic>? _currentNight;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Map<String, dynamic>?>? _subscription;

  Map<String, dynamic>? get currentNight => _currentNight;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Escucha los cambios de una noche específica en tiempo real
  void listenToNight(String nightId) {
    _subscription?.cancel();
    _subscription = _nightService.streamNight(nightId).listen(
      (nightData) {
        _currentNight = nightData;
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Limpia la suscripción y los datos de la noche actual
  void clear() {
    _subscription?.cancel();
    _currentNight = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Unirse a una noche (actualiza en Firestore y refresca el provider)
  Future<void> joinNight(String nightId, String userId, String userName, String userInitials) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _nightService.joinNight(nightId, userId, userName, userInitials);
      _error = null;
      // No es necesario recargar porque el stream lo hará automáticamente
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Completar un reto
  Future<void> completeChallenge(String nightId, int challengeIndex, String playerName, Uint8List? proofBytes) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _nightService.completeChallenge(nightId, challengeIndex, playerName, proofBytes);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Añadir una foto a la noche
  Future<void> addNightPhoto(String nightId, Uint8List photoBytes) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _nightService.addNightPhoto(nightId, photoBytes);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Finalizar la noche (marcar como finished)
  Future<void> finishNight(String nightId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _nightService.finishNight(nightId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
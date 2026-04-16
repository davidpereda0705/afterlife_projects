import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/night_service.dart';

class NightProvider extends ChangeNotifier {
  final NightService _nightService = NightService();
  
  Map<String, dynamic>? _currentNight;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Map<String, dynamic>?>? _subscription;

  Map<String, dynamic>? get currentNight => _currentNight;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToNight(String nightId) {
    // Cancelar suscripción anterior
    _subscription?.cancel();
    
    // Escuchar el stream y manejar errores dentro de listen
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

  void clear() {
    _subscription?.cancel();
    _currentNight = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> joinNight(String nightId, String userId, String userName, String userInitials) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _nightService.joinNight(nightId, userId, userName, userInitials);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
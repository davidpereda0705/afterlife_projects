import 'package:flutter/material.dart';

class ActiveNightManager {
  static final ActiveNightManager _instance = ActiveNightManager._internal();
  factory ActiveNightManager() => _instance;
  ActiveNightManager._internal();

  final ValueNotifier<Map<String, dynamic>?> _activeNightNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  ValueNotifier<Map<String, dynamic>?> get activeNight => _activeNightNotifier;

  bool get isActive => _activeNightNotifier.value != null;

  void setActiveNight(Map<String, dynamic> nightData) {
    _activeNightNotifier.value = nightData;
  }

  void clearActiveNight() {
    _activeNightNotifier.value = null;
  }
}
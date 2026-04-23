import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/level_calculator.dart';
import '../models/achievement.dart';
import '../core/app_constants.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa los logros por defecto en Firestore si la colección está vacía.
  Future<void> initializeDefaultAchievements() async {
    final snapshot = await _firestore.collection(AppConstants.achievementsCollection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final defaultAchievements = [
      {"title": "SOCIAL", "icon": "Icons.people", "description": "Únete a 5 noches", "category": "nights", "requirement": 5, "points": 100, "active": true},
      {"title": "NO VETERANO", "icon": "Icons.military_tech", "description": "Completa tu primera noche", "category": "nights", "requirement": 1, "points": 50, "active": true},
      {"title": "FIESTERO", "icon": "Icons.nightlife", "description": "Asiste a 10 noches", "category": "nights", "requirement": 10, "points": 200, "active": true},
      {"title": "INFLUENCER", "icon": "Icons.camera_alt", "description": "Sube 5 fotos de retos", "category": "photos", "requirement": 5, "points": 150, "active": true},
      {"title": "LEYENDA", "icon": "Icons.stars", "description": "Completa 50 retos", "category": "challenges", "requirement": 50, "points": 500, "active": true},
      {"title": "MAESTRO", "icon": "Icons.school", "description": "Crea 10 noches", "category": "nights_created", "requirement": 10, "points": 300, "active": true},
      {"title": "INQUEBRANTABLE", "icon": "Icons.verified", "description": "Nivel 25", "category": "level", "requirement": 25, "points": 400, "active": true},
      {"title": "SOCIALITE", "icon": "Icons.diversity_3", "description": "Ten 20 amigos", "category": "friends", "requirement": 20, "points": 250, "active": true},
      {"title": "NOCTÁMBULO", "icon": "Icons.nights_stay", "description": "100 noches", "category": "nights", "requirement": 100, "points": 1000, "active": true},
      {"title": "LEYENDA VIVA", "icon": "Icons.auto_awesome", "description": "Completa todos los logros", "category": "custom", "requirement": 1, "points": 2000, "active": true},
    ];

    final batch = _firestore.batch();
    for (var achievement in defaultAchievements) {
      final docRef = _firestore.collection(AppConstants.achievementsCollection).doc();
      batch.set(docRef, achievement);
    }
    await batch.commit();
    debugPrint('✅ Logros iniciales creados en Firestore');
  }

  Future<List<Achievement>> getAllAchievements() async {
    final snapshot = await _firestore.collection(AppConstants.achievementsCollection).where('active', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Achievement.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<String>> getUnlockedAchievementIds(String userId) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
    final unlocked = doc.data()?[AppConstants.fieldUnlockedAchievements] as List? ?? [];
    return unlocked.map((e) => e['achievementId'] as String).toList();
  }

  Future<List<Achievement>> checkAndUnlockAchievements({
    required String userId,
    required int nightsCompleted,
    required int challengesCompleted,
    required int level,
    required int friendsCount,
    required int photosUploaded,
    required int nightsCreated,
  }) async {
    final allAchievements = await getAllAchievements();
    final alreadyUnlocked = await getUnlockedAchievementIds(userId);
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (alreadyUnlocked.contains(achievement.id)) continue;

      bool achieved = false;
      switch (achievement.category) {
        case AppConstants.nightsCollection: achieved = nightsCompleted >= achievement.requirement; break;
        case AppConstants.fieldChallenges: achieved = challengesCompleted >= achievement.requirement; break;
        case AppConstants.fieldLevel: achieved = level >= achievement.requirement; break;
        case 'friends': achieved = friendsCount >= achievement.requirement; break;
        case 'photos': achieved = photosUploaded >= achievement.requirement; break;
        case 'nights_created': achieved = nightsCreated >= achievement.requirement; break;
        default: break;
      }
      if (achieved) newlyUnlocked.add(achievement);
    }

    if (newlyUnlocked.isNotEmpty) {
      await _unlockAchievements(userId, newlyUnlocked);
    }
    return newlyUnlocked;
  }

  Future<void> _unlockAchievements(String userId, List<Achievement> achievements) async {
    final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
    final userDoc = await userRef.get();
    final currentUnlocked = List<Map<String, dynamic>>.from(userDoc.data()?[AppConstants.fieldUnlockedAchievements] ?? []);
    final totalPointsToAdd = achievements.fold(0, (sum, a) => sum + a.points);

    for (final achievement in achievements) {
      currentUnlocked.add({
        'achievementId': achievement.id,
        'unlockedAt': FieldValue.serverTimestamp(),
        'pointsEarned': achievement.points,
      });
    }

    final currentPoints = userDoc.data()?[AppConstants.fieldPoints] ?? 0;
    final newPoints = currentPoints + totalPointsToAdd;
    final newLevel = _calculateLevel(newPoints);
    final currentLevel = userDoc.data()?[AppConstants.fieldLevel] ?? 1;

    final updates = {
      AppConstants.fieldUnlockedAchievements: currentUnlocked,
      AppConstants.fieldPoints: newPoints,
    };
    if (newLevel != currentLevel) {
      updates[AppConstants.fieldLevel] = newLevel;
    }

    await userRef.update(updates);
  }

  int _calculateLevel(int points) {
    return LevelCalculator.calculate(points);
  }

  double getProgress(Achievement achievement, {
    required int nightsCompleted,
    required int challengesCompleted,
    required int level,
    required int friendsCount,
    required int photosUploaded,
    required int nightsCreated,
  }) {
    int current = 0;
    switch (achievement.category) {
      case AppConstants.nightsCollection: current = nightsCompleted; break;
      case AppConstants.fieldChallenges: current = challengesCompleted; break;
      case AppConstants.fieldLevel: current = level; break;
      case 'friends': current = friendsCount; break;
      case 'photos': current = photosUploaded; break;
      case 'nights_created': current = nightsCreated; break;
      default: break;
    }
    return (current / achievement.requirement).clamp(0.0, 1.0);
  }
}
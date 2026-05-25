// Constantes globales de la app: nombres de colecciones de Firestore,
// límites, configuraciones fijas y otros valores inmutables.
//
// Por qué usar esta clase:
//   - Evita tener "magic strings" (cadenas literales) dispersas por el código.
//   - Un solo cambio aquí actualiza todos los usos en la app.
//   - Mejora la detección de errores tipográficos en tiempo de compilación.
class AppConstants {
  const AppConstants._(); // Constructor privado: clase no instanciable

  // Colecciones de Firestore
  static const String usersCollection = 'users';
  static const String nightsCollection = 'nights';
  static const String achievementsCollection = 'achievements';

  // Campos de usuario frecuentes
  static const String fieldUsername = 'username';
  static const String fieldEmail = 'email';
  static const String fieldLevel = 'level';
  static const String fieldPoints = 'points';
  static const String fieldNightsCompleted = 'nightsCompleted';
  static const String fieldChallengesCompleted = 'challengesCompleted';
  static const String fieldFriendsCount = 'friendsCount';
  static const String fieldPhotosUploaded = 'photosUploaded';
  static const String fieldNightsCreated = 'nightsCreated';
  static const String fieldUnlockedAchievements = 'unlockedAchievements';
  static const String fieldActiveNightId = 'activeNightId';
  static const String fieldCreatedAt = 'createdAt';

  // Campos de noche
  static const String fieldNightName = 'name';
  static const String fieldHostId = 'hostId';
  static const String fieldHostName = 'hostName';
  static const String fieldHostInitials = 'hostInitials';
  static const String fieldGroupName = 'groupName';
  static const String fieldDay = 'day';
  static const String fieldTime = 'time';
  static const String fieldMaxPlayers = 'maxPlayers';
  static const String fieldPlayers = 'players';
  static const String fieldChallenges = 'challenges';
  static const String fieldNightPhotos = 'nightPhotos';
  static const String fieldStatus = 'status';

  // SharedPreferences
  static const String prefHasSeenOnboarding = 'has_seen_onboarding';
}

// lib/core/enums.dart

/// Estados posibles de una noche en la app.
enum NightStatus {
  waiting,
  inProgress,
  finished;

  String get value {
    switch (this) {
      case NightStatus.waiting:
        return 'waiting';
      case NightStatus.inProgress:
        return 'in_progress';
      case NightStatus.finished:
        return 'finished';
    }
  }

  static NightStatus fromString(String? status) {
    switch (status) {
      case 'in_progress':
        return NightStatus.inProgress;
      case 'finished':
        return NightStatus.finished;
      case 'waiting':
      default:
        return NightStatus.waiting;
    }
  }
}

/// Tipos de retos disponibles.
enum ChallengeType {
  group,
  individual,
  competitive;

  String get displayName {
    switch (this) {
      case ChallengeType.group:
        return 'Grupal';
      case ChallengeType.individual:
        return 'Individual';
      case ChallengeType.competitive:
        return 'Competitivo';
    }
  }
}

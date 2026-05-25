// Enums compartidos entre modelos, servicios y providers.
// Se definen aquí para no crear dependencias circulares entre archivos.

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

  /// Convierte el string de Firestore al enum.
  /// El default es 'waiting' para que documentos sin campo 'status' sean tratados como pendientes.
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

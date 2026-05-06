// lib/data/challenge_bank.dart
import 'package:afterlife_projects/core/enums.dart';

class Challenge {
  final String name;
  final int points;
  final ChallengeType type;

  const Challenge(this.name, this.points, this.type);
}

class ChallengeBank {
  static const List<Challenge> _challenges = [
    // Grupal
    Challenge('Selfie con todo el grupo', 100, ChallengeType.group),
    Challenge('Haz reír a todos del grupo', 130, ChallengeType.group),
    Challenge('Foto grupal con un desconocido', 120, ChallengeType.group),
    Challenge('Baila en círculo todos juntos', 90, ChallengeType.group),
    Challenge('Haced una coreografía de 15 segundos', 150, ChallengeType.group),
    Challenge('Foto imitando una portada de disco', 110, ChallengeType.group),
    Challenge('Todos a cantar una canción a coro', 140, ChallengeType.group),
    Challenge('Haced una pirámide humana', 160, ChallengeType.group),
    Challenge('Foto con la ropa intercambiada', 130, ChallengeType.group),
    Challenge('Recrea una escena de película famosa', 140, ChallengeType.group),
    Challenge('Todos con los zapatos intercambiados', 100, ChallengeType.group),
    Challenge('Haced el tren humano por la sala', 110, ChallengeType.group),
    Challenge('Foto besándoos todos en la mejilla', 120, ChallengeType.group),
    Challenge('Imitad a un animal cada uno', 90, ChallengeType.group),
    Challenge('Haced una competición de limbo', 130, ChallengeType.group),
    Challenge('Todos hacen el robot durante 30 segundos', 120, ChallengeType.group),
    Challenge('El grupo inventa una coreografía de 10 segundos', 140, ChallengeType.group),
    Challenge('Todos cantan el estribillo de una canción juntos', 130, ChallengeType.group),
    Challenge('Foto grupal con todos saltando', 110, ChallengeType.group),
    Challenge('El grupo hace una pirámide humana', 160, ChallengeType.group),
    Challenge('Todos dan un aplauso sincronizado 10 veces', 90, ChallengeType.group),
    Challenge('Cadena de chistes: cada uno cuenta uno', 120, ChallengeType.group),
    Challenge('Todos imitan al jugador que indique el anfitrión', 100, ChallengeType.group),

    // Individual
    Challenge('Baila con un desconocido', 150, ChallengeType.individual),
    Challenge('Foto con el DJ o animador', 120, ChallengeType.individual),
    Challenge('Canta una canción completa en karaoke', 200, ChallengeType.individual),
    Challenge('Haz 10 flexiones en medio de la pista', 140, ChallengeType.individual),
    Challenge('Pide un autógrafo a un extraño', 110, ChallengeType.individual),
    Challenge('Habla con acento extranjero durante 5 min', 130, ChallengeType.individual),
    Challenge('Haz el moonwalk por la sala', 120, ChallengeType.individual),
    Challenge('Declara tu amor a una silla', 100, ChallengeType.individual),
    Challenge('Imita a un personaje famoso', 110, ChallengeType.individual),
    Challenge('Haz una declaración épica al grupo', 140, ChallengeType.individual),
    Challenge('Dibuja un retrato de alguien con los ojos cerrados', 90, ChallengeType.individual),
    Challenge('Cuenta un chiste que haga reír a todos', 120, ChallengeType.individual),
    Challenge('Haz una voltereta (o inténtalo)', 130, ChallengeType.individual),
    Challenge('Pide la hora a 5 desconocidos', 100, ChallengeType.individual),
    Challenge('Hazte una foto haciendo el pino', 150, ChallengeType.individual),
    Challenge('Baila durante 1 minuto sin parar', 140, ChallengeType.individual),
    Challenge('Di 5 palabras en otro idioma', 100, ChallengeType.individual),
    Challenge('Imita a un personaje famoso hasta que alguien te adivine', 130, ChallengeType.individual),
    Challenge('Haz 10 sentadillas sin perder el ritmo', 110, ChallengeType.individual),
    Challenge('Canta una canción en inglés con los ojos cerrados', 150, ChallengeType.individual),
    Challenge('Di el alfabeto al revés lo más rápido que puedas', 120, ChallengeType.individual),
    Challenge('Haz una postura de yoga por 30 segundos', 100, ChallengeType.individual),

    // Competitivo
    Challenge('Consigue que un extraño te dé su número', 180, ChallengeType.competitive),
    Challenge('Gana una partida de piedra-papel-tijera al anfitrión', 140, ChallengeType.competitive),
    Challenge('Sé el primero en conseguir una foto con 3 desconocidos', 200, ChallengeType.competitive),
    Challenge('Gana una carrera de sacos (o simulada)', 160, ChallengeType.competitive),
    Challenge('Quien bebe más agua en 30 segundos', 130, ChallengeType.competitive),
    Challenge('Competición de miradas: el que parpadea pierde', 120, ChallengeType.competitive),
    Challenge('Quién hace más sentadillas en 1 minuto', 150, ChallengeType.competitive),
    Challenge('Duelo de baile: el grupo vota', 170, ChallengeType.competitive),
    Challenge('Quién aguanta más tiempo en una pierna', 140, ChallengeType.competitive),
    Challenge('Competición de tirar una bola de papel a la papelera', 130, ChallengeType.competitive),
    Challenge('Quién dice el abecedario más rápido', 110, ChallengeType.competitive),
    Challenge('Duelo de imitaciones: el grupo juzga', 160, ChallengeType.competitive),
    Challenge('Quién encuentra algo de color amarillo más rápido', 100, ChallengeType.competitive),
    Challenge('Competición de chistes: el grupo vota el mejor', 150, ChallengeType.competitive),
    Challenge('Quién hace más giros sobre sí mismo sin caerse', 140, ChallengeType.competitive),
    Challenge('Duelo de pull&bear (tirar de la cuerda)', 170, ChallengeType.competitive),
    Challenge('Quién mantiene una pose de yoga más tiempo', 130, ChallengeType.competitive),
    Challenge('Competición de no reír: el último en reír gana', 160, ChallengeType.competitive),
    Challenge('Quién encuentra algo redondo más rápido', 100, ChallengeType.competitive),
    Challenge('Duelo de freestyle (improvisación de rap)', 190, ChallengeType.competitive),
    Challenge('¿Quién puede hacer más sentadillas en 30 segundos?', 150, ChallengeType.competitive),
    Challenge('¿Quién adivina más canciones con solo 5 segundos?', 160, ChallengeType.competitive),
    Challenge('¿Quién recuerda más nombres de películas del año pasado?', 130, ChallengeType.competitive),
    Challenge('Concurso de mejor chiste: el grupo vota', 140, ChallengeType.competitive),
    Challenge('¿Quién aguanta más tiempo con una postura graciosa?', 120, ChallengeType.competitive),
    Challenge('Batalla de baile: 30 segundos cada uno, el grupo vota', 180, ChallengeType.competitive),
    Challenge('¿Quién imita mejor a una persona famosa?', 160, ChallengeType.competitive),
  ];

  static List<Challenge> getByType(ChallengeType type) =>
      _challenges.where((c) => c.type == type).toList();

  static List<Challenge> getRandom({int count = 5, List<ChallengeType>? types}) {
    final pool = types != null
        ? _challenges.where((c) => types.contains(c.type)).toList()
        : List<Challenge>.from(_challenges);
    pool.shuffle();
    return pool.take(count).toList();
  }

  static List<Challenge> get all => List.unmodifiable(_challenges);
}

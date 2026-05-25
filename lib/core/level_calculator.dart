// Lógica centralizada de cálculo de nivel.
// Al tenerla aquí (en lugar de duplicarla en UserProvider y AchievementService),
// garantizamos que ambos usen siempre la misma fórmula.

class LevelCalculator {
  const LevelCalculator._(); // No instanciable

  /// Calcula el nivel según los puntos totales.
  /// Fórmula: nivel = 1 + (puntos / 100).
  /// Ejemplo: 0–99 pts → nivel 1, 100–199 → nivel 2, etc.
  /// El operador ~/ es división entera en Dart (equivalente a floor(a/b)).
  static int calculate(int points) {
    if (points < 0) return 1;
    return 1 + (points ~/ 100);
  }
}

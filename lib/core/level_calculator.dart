// lib/core/level_calculator.dart

class LevelCalculator {
  const LevelCalculator._();

  /// Calcula el nivel según los puntos totales.
  /// Fórmula: nivel = 1 + (puntos / 100).
  static int calculate(int points) {
    if (points < 0) return 1;
    return 1 + (points ~/ 100);
  }
}

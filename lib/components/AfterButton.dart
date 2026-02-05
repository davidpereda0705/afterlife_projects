import 'package:flutter/material.dart';
import '../theme/colors.dart'; //

class AfterButton extends StatelessWidget {
  final String label;         // El texto que tú quieras ponerle
  final VoidCallback onPressed; // La acción que tú quieras que haga
  final Color color;          // El color que tú elijas
  final double size;           // El tamaño que decidas

  const AfterButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AfterlifeColors.electricPurple, // Color por defecto si no pones ninguno
    this.size = 80.0, // Tamaño por defecto
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size, // Lo mantenemos cuadrado como pediste
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15), //
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 4), //
            ),
          ],
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: size * 0.2, // La fuente se adapta al tamaño del botón
            ),
          ),
        ),
      ),
    );
  }
}
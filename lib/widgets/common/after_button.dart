import 'package:flutter/material.dart';

class AfterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Cambiado a opcional
  final Color color;

  const AfterButton({
    super.key,
    required this.label,
    this.onPressed, // Ya no es required, puede ser null
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDisabled ? color.withValues(alpha: 0.3) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 25,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

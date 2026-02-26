import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AfterProgressBar extends StatelessWidget {
  final double progress; // Valor de 0.0 a 1.0
  final Color color;
  final String label;

  const AfterProgressBar({
    super.key,
    required this.progress,
    this.color = AfterlifeColors.electricPurple,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Parte rellena de la barra
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
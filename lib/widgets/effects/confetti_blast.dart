// Wrapper de confetti: lanza partículas de celebración sobre cualquier pantalla.
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiBlast extends StatefulWidget {
  final Widget child;
  final ConfettiController controller;
  final double blastDirection;

  const ConfettiBlast({
    super.key,
    required this.child,
    required this.controller,
    this.blastDirection = -pi / 2,
  });

  @override
  State<ConfettiBlast> createState() => _ConfettiBlastState();
}

class _ConfettiBlastState extends State<ConfettiBlast> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: widget.controller,
            blastDirection: widget.blastDirection,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [
              Color(0xFFA855F7),
              Color(0xFFEC4899),
              Color(0xFF06B6D4),
              Color(0xFF84CC16),
              Color(0xFFF59E0B),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
      ],
    );
  }
}

class ConfettiTrigger extends StatelessWidget {
  final VoidCallback onTap;
  final ConfettiController controller;
  final Widget child;

  const ConfettiTrigger({
    super.key,
    required this.onTap,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.play();
        onTap();
      },
      child: ConfettiBlast(
        controller: controller,
        child: child,
      ),
    );
  }
}

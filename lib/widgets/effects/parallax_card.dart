// Tarjeta con efecto parallax: se inclina levemente según el movimiento del giroscopio del dispositivo.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParallaxCard extends StatefulWidget {
  final Widget child;
  final double intensity;
  final BorderRadius? borderRadius;

  const ParallaxCard({
    super.key,
    required this.child,
    this.intensity = 8.0,
    this.borderRadius,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  double _x = 0;
  double _y = 0;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen((event) {
      if (mounted) {
        setState(() {
          // event.x: left/right tilt, event.y: forward/back tilt
          // Clamp to avoid extreme movement
          _x = (-event.x).clamp(-3.0, 3.0) / 3.0;
          _y = (event.y).clamp(-3.0, 3.0) / 3.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dx = _x * widget.intensity;
    final dy = _y * widget.intensity;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(dy * 0.02)
        ..rotateY(dx * 0.02),
      alignment: FractionalOffset.center,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: widget.child,
      ),
    );
  }
}

class ParallaxStack extends StatelessWidget {
  final List<Widget> children;
  final double baseIntensity;

  const ParallaxStack({
    super.key,
    required this.children,
    this.baseIntensity = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final depth = (entry.key + 1) * 0.3;
        return ParallaxCard(
          intensity: baseIntensity * depth,
          child: entry.value,
        );
      }).toList(),
    );
  }
}

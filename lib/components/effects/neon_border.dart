import 'dart:math';
import 'package:flutter/material.dart';

class NeonBorder extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double strokeWidth;
  final double blurRadius;
  final Duration duration;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const NeonBorder({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFFA855F7),
    ],
    this.strokeWidth = 2.5,
    this.blurRadius = 12,
    this.duration = const Duration(seconds: 3),
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  State<NeonBorder> createState() => _NeonBorderState();
}

class _NeonBorderState extends State<NeonBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: widget.colors[0].withValues(alpha: 0.35),
                blurRadius: widget.blurRadius,
                spreadRadius: widget.blurRadius * 0.2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _RunningGlowPainter(
              progress: _controller.value,
              colors: widget.colors,
              strokeWidth: widget.strokeWidth,
              blurRadius: widget.blurRadius,
              radius: radius,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _RunningGlowPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;
  final double blurRadius;
  final BorderRadius radius;

  _RunningGlowPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
    required this.blurRadius,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: radius.topLeft,
      topRight: radius.topRight,
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    // Create a gradient that moves along the path
    final gradientColors = <Color>[];
    final gradientStops = <double>[];
    final segments = colors.length - 1;

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      gradientColors.add(colors[i]);
      gradientStops.add((t + progress) % 1.0);
    }

    // Sort by stops
    final combined = List.generate(gradientColors.length, (i) => (gradientStops[i], gradientColors[i]));
    combined.sort((a, b) => a.$1.compareTo(b.$1));

    final sortedColors = combined.map((e) => e.$2).toList();
    final sortedStops = combined.map((e) => e.$1).toList();

    // We need to create a shader along the path. We'll approximate by drawing
    // many small segments with interpolated colors.
    const steps = 120;
    for (int i = 0; i < steps; i++) {
      final t1 = i / steps;
      final t2 = (i + 1) / steps;

      final pos1 = pathMetrics.getTangentForOffset(t1 * pathLength)!.position;
      final pos2 = pathMetrics.getTangentForOffset(t2 * pathLength)!.position;

      final colorT = (t1 + progress) % 1.0;
      final color = _interpolateColors(sortedColors, sortedStops, colorT);

      final segmentPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius / 3);

      canvas.drawLine(pos1, pos2, segmentPaint);
    }

    // Draw the sharp core line
    final corePaint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        transform: GradientRotation(progress * pi * 2),
      ).createShader(rect)
      ..strokeWidth = strokeWidth * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, corePaint);
  }

  Color _interpolateColors(List<Color> colors, List<double> stops, double t) {
    if (t <= stops.first) return colors.first;
    if (t >= stops.last) return colors.last;

    for (int i = 0; i < stops.length - 1; i++) {
      if (t >= stops[i] && t <= stops[i + 1]) {
        final localT = (t - stops[i]) / (stops[i + 1] - stops[i]);
        return Color.lerp(colors[i], colors[i + 1], localT)!;
      }
    }
    return colors.last;
  }

  @override
  bool shouldRepaint(covariant _RunningGlowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

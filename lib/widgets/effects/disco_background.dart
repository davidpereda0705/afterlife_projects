import 'dart:math';
import 'package:flutter/material.dart';

class DiscoBackground extends StatefulWidget {
  final Widget child;
  const DiscoBackground({super.key, required this.child});

  @override
  State<DiscoBackground> createState() => _DiscoBackgroundState();
}

class _DiscoBackgroundState extends State<DiscoBackground>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_LightParticle> _particles = [];
  final List<_Spotlight> _spotlights = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _initParticles();
    _initSpotlights();
  }

  void _initParticles() {
    const colorsDark = [
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF84CC16),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    const colorsLight = [
      Color(0x40A855F7),
      Color(0x40EC4899),
      Color(0x4006B6D4),
      Color(0x4084CC16),
      Color(0x40F59E0B),
      Color(0x408B5CF6),
    ];

    for (int i = 0; i < 10; i++) {
      _particles.add(_LightParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        baseSize: 40 + _random.nextDouble() * 120,
        speedX: (_random.nextDouble() - 0.5) * 0.0008,
        speedY: (_random.nextDouble() - 0.5) * 0.0006,
        phase: _random.nextDouble() * pi * 2,
        pulseSpeed: 0.5 + _random.nextDouble() * 1.5,
        colorsDark: colorsDark,
        colorsLight: colorsLight,
        colorIndex: _random.nextInt(colorsDark.length),
      ));
    }
  }

  void _initSpotlights() {
    const colors = [
      Color(0xFFD8B4FE), // lila pastel
      Color(0xFFFBCFE8), // rosa pastel
      Color(0xFFA5F3FC), // cian pastel
      Color(0xFFD9F99D), // verde pastel
      Color(0xFFFDE68A), // amarillo pastel
      Color(0xFFC4B5FD), // violeta pastel
    ];

    for (int i = 0; i < 3; i++) {
      _spotlights.add(_Spotlight(
        originX: 0.1 + _random.nextDouble() * 0.8,
        originY: -0.2,
        anglePhase: _random.nextDouble() * pi * 2,
        sweepSpeed: 0.3 + _random.nextDouble() * 0.7,
        sweepRange: 0.4 + _random.nextDouble() * 0.6,
        baseWidth: 120 + _random.nextDouble() * 200,
        reach: 0.6 + _random.nextDouble() * 0.5,
        color: colors[i % colors.length],
        pulsePhase: _random.nextDouble() * pi * 2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _DiscoPainter(
            particles: _particles,
            spotlights: _spotlights,
            progress: _controller.value,
            isDark: isDark,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _LightParticle {
  double x, y;
  final double baseSize;
  final double speedX;
  final double speedY;
  final double phase;
  final double pulseSpeed;
  final List<Color> colorsDark;
  final List<Color> colorsLight;
  final int colorIndex;

  _LightParticle({
    required this.x,
    required this.y,
    required this.baseSize,
    required this.speedX,
    required this.speedY,
    required this.phase,
    required this.pulseSpeed,
    required this.colorsDark,
    required this.colorsLight,
    required this.colorIndex,
  });

  Color color(bool isDark) => isDark ? colorsDark[colorIndex] : colorsLight[colorIndex];
}

class _Spotlight {
  final double originX;
  final double originY;
  final double anglePhase;
  final double sweepSpeed;
  final double sweepRange;
  final double baseWidth;
  final double reach;
  final Color color;
  final double pulsePhase;

  _Spotlight({
    required this.originX,
    required this.originY,
    required this.anglePhase,
    required this.sweepSpeed,
    required this.sweepRange,
    required this.baseWidth,
    required this.reach,
    required this.color,
    required this.pulsePhase,
  });
}

class _DiscoPainter extends CustomPainter {
  final List<_LightParticle> particles;
  final List<_Spotlight> spotlights;
  final double progress;
  final bool isDark;

  _DiscoPainter({
    required this.particles,
    required this.spotlights,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    final basePaint = Paint();
    if (isDark) {
      basePaint.color = const Color(0xFF000000);
    } else {
      basePaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8F5FF), Color(0xFFFFF5F8), Color(0xFFF5FDFF)],
      ).createShader(Offset.zero & size);
    }
    canvas.drawRect(Offset.zero & size, basePaint);

    if (!isDark) {
      _paintSpotlights(canvas, size);
    }

    for (final p in particles) {
      final t = progress * pi * 2;
      final px = (p.x + p.speedX * t * 1000) % 1.0;
      final py = (p.y + p.speedY * t * 1000) % 1.0;
      final pulse = 0.6 + 0.4 * sin(t * p.pulseSpeed + p.phase);
      final radius = p.baseSize * pulse;
      final opacity = isDark ? 0.15 * pulse : 0.12 * pulse;

      final center = Offset(px * size.width, py * size.height);

      final gradient = RadialGradient(
        colors: [
          p.color(isDark).withValues(alpha: opacity),
          p.color(isDark).withValues(alpha: opacity * 0.5),
          p.color(isDark).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..blendMode = isDark ? BlendMode.screen : BlendMode.srcOver;

      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintSpotlights(Canvas canvas, Size size) {
    final t = progress * pi * 2;

    for (final s in spotlights) {
      // Movimiento de barrido del foco
      final sweep = sin(t * s.sweepSpeed + s.anglePhase) * s.sweepRange;
      final origin = Offset(s.originX * size.width, s.originY * size.height);

      // Ángulo del haz (apuntando hacia abajo con barrido lateral)
      final angle = pi / 2 + sweep * 0.6;

      // Pulso de intensidad
      final pulse = 0.5 + 0.5 * sin(t * 1.2 + s.pulsePhase);
      final width = s.baseWidth * (0.8 + 0.2 * pulse);
      final length = size.height * s.reach * (0.9 + 0.1 * pulse);

      // Construimos el haz como un gradiente lineal muy difuminado
      final endPoint = Offset(
        origin.dx + cos(angle) * length,
        origin.dy + sin(angle) * length,
      );

      // Dibujamos el haz principal
      final path = Path();
      final perpX = cos(angle + pi / 2);
      final perpY = sin(angle + pi / 2);

      path.moveTo(origin.dx + perpX * width * 0.3, origin.dy + perpY * width * 0.3);
      path.lineTo(endPoint.dx + perpX * width, endPoint.dy + perpY * width);
      path.lineTo(endPoint.dx - perpX * width, endPoint.dy - perpY * width);
      path.lineTo(origin.dx - perpX * width * 0.3, origin.dy - perpY * width * 0.3);
      path.close();

      final spotlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            s.color.withValues(alpha: 0.35 * pulse),
            s.color.withValues(alpha: 0.15 * pulse),
            s.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromPoints(origin, endPoint))
        ..blendMode = BlendMode.srcOver;

      canvas.drawPath(path, spotlightPaint);

      // Halo en el origen del foco (la "cabeza" del foco)
      final headPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            s.color.withValues(alpha: 0.5 * pulse),
            s.color.withValues(alpha: 0.2 * pulse),
            s.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.3, 1.0],
        ).createShader(Rect.fromCircle(center: origin, radius: width * 0.8))
        ..blendMode = BlendMode.srcOver;

      canvas.drawCircle(origin, width * 0.8, headPaint);

      // Mancha de luz en el suelo (donde cae el foco)
      final floorCenter = Offset(
        endPoint.dx,
        size.height * 0.95,
      );

      final floorPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            s.color.withValues(alpha: 0.25 * pulse),
            s.color.withValues(alpha: 0.08 * pulse),
            s.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: floorCenter, radius: width * 1.5))
        ..blendMode = BlendMode.srcOver;

      canvas.drawCircle(floorCenter, width * 1.5, floorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiscoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}

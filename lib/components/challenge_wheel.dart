import 'dart:math';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChallengeWheel extends StatefulWidget {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>>? challenges;
  final VoidCallback? onSpin;

  const ChallengeWheel({
    super.key,
    required this.players,
    this.challenges,
    this.onSpin,
  });

  @override
  State<ChallengeWheel> createState() => _ChallengeWheelState();
}

class _ChallengeWheelState extends State<ChallengeWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;
  int? _selectedIndex;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.addListener(() {
      setState(() {
        _angle = _controller.value * 2 * pi * 5 + _initialAngle;
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        HapticFeedback.heavyImpact();
      }
    });
  }

  double get _initialAngle => _selectedIndex != null
      ? -(_selectedIndex! / widget.players.length) * 2 * pi
      : 0;

  void _spin() {
    if (_isSpinning || widget.players.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSpinning = true);
    _selectedIndex = Random().nextInt(widget.players.length);
    _controller.forward(from: 0);
    widget.onSpin?.call();
  }

  String get _selectedName {
    if (_selectedIndex == null) return '?';
    final p = widget.players[_selectedIndex!];
    return p['username'] ?? p['name'] ?? '?';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      AfterlifeColors.electricPurple,
      AfterlifeColors.neonPink,
      AfterlifeColors.cyanBlue,
      AfterlifeColors.acidGreen,
      AfterlifeColors.neonOrange,
      AfterlifeColors.electricLilac,
    ];

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rueda
              Transform.rotate(
                angle: _angle,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _WheelPainter(
                    players: widget.players,
                    colors: colors,
                  ),
                ),
              ),
              // Centro
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AfterlifeColors.electricPurple, width: 3),
                ),
                child: IconButton(
                  icon: const Icon(Icons.casino, size: 20),
                  onPressed: _spin,
                ),
              ),
              // Flecha indicadora (arriba)
              Positioned(
                top: 0,
                child: Icon(Icons.arrow_drop_down, size: 36, color: AfterlifeColors.neonPink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedIndex != null && !_isSpinning)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AfterlifeColors.electricPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AfterlifeColors.electricPurple),
            ),
            child: Text(
              '¡TOCA: $_selectedName!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> players;
  final List<Color> colors;

  _WheelPainter({required this.players, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / players.length;

    for (int i = 0; i < players.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2 + i * segmentAngle,
          segmentAngle,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);

      // Dibujar nombre
      final textAngle = -pi / 2 + i * segmentAngle + segmentAngle / 2;
      final textOffset = Offset(
        center.dx + cos(textAngle) * (radius * 0.65),
        center.dy + sin(textAngle) * (radius * 0.65),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: (players[i]['username'] ?? players[i]['name'] ?? '?').toString().substring(0, min(4, (players[i]['username'] ?? players[i]['name'] ?? '?').toString().length)),
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

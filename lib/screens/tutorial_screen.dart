import 'dart:math';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onDone;
  const TutorialScreen({super.key, required this.onDone});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  final PageController _page = PageController();
  int _current = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _total = 5;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _page.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _total - 1) {
      _page.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  void _onPageChanged(int index) {
    setState(() => _current = index);
    _fadeCtrl.reset();
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Fondo degradado animado
          const Positioned.fill(child: _AnimatedBg()),

          // PageView con slides
          PageView(
            controller: _page,
            onPageChanged: _onPageChanged,
            children: [
              _Slide0Welcome(fade: _fade, size: size),
              _Slide1Night(fade: _fade, size: size),
              _Slide2Challenges(fade: _fade, size: size),
              _Slide3Minigames(fade: _fade, size: size),
              _Slide4Ranking(fade: _fade, size: size),
            ],
          ),

          // Skip (top right)
          if (_current < _total - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: GestureDetector(
                onTap: widget.onDone,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Text(
                    'SALTAR',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

          // Dots + Botón
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_total, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? AfterlifeColors.electricPurple
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Botón principal
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AfterlifeColors.electricPurple,
                          AfterlifeColors.neonPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AfterlifeColors.electricPurple
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      _current == _total - 1 ? '¡EMPEZAR!' : 'SIGUIENTE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fondo animado ────────────────────────────────────────────────────────────

class _AnimatedBg extends StatefulWidget {
  const _AnimatedBg();

  @override
  State<_AnimatedBg> createState() => _AnimatedBgState();
}

class _AnimatedBgState extends State<_AnimatedBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * 2 * pi;
        return CustomPaint(painter: _BgPainter(t));
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF000000));

    final orbs = [
      (0.2, 0.15, const Color(0xFFA855F7), 180.0),
      (0.8, 0.25, const Color(0xFFEC4899), 140.0),
      (0.5, 0.6, const Color(0xFF06B6D4), 160.0),
    ];

    for (final o in orbs) {
      final px = o.$1 + sin(t * 0.4 + o.$4) * 0.05;
      final py = o.$2 + cos(t * 0.3 + o.$4) * 0.04;
      final pulse = 0.7 + 0.3 * sin(t + o.$4);
      final center = Offset(px * size.width, py * size.height);
      final radius = o.$4 * pulse;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              (o.$3).withValues(alpha: 0.18 * pulse),
              (o.$3).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..blendMode = BlendMode.screen,
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ─── Helper: contenedor de slide ─────────────────────────────────────────────

class _SlideShell extends StatelessWidget {
  final Animation<double> fade;
  final Widget visual;
  final String title;
  final String subtitle;

  const _SlideShell({
    required this.fade,
    required this.visual,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: fade,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 60,
          24,
          160,
        ),
        child: Column(
          children: [
            // Visual
            Expanded(
              child: Center(
                child: SizedBox(
                  width: size.width - 48,
                  child: visual,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            // Subtítulo
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Slide 0: Bienvenida ──────────────────────────────────────────────────────

class _Slide0Welcome extends StatelessWidget {
  final Animation<double> fade;
  final Size size;
  const _Slide0Welcome({required this.fade, required this.size});

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      fade: fade,
      title: 'Bienvenido a Afterlife 🌙',
      subtitle: 'La app que convierte cada salida en una aventura',
      visual: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/imatges/logo_afterlife.png',
            height: size.height * 0.35,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 28),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AfterlifeColors.electricPurple.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎉', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'RETOS · NOCHES · LOGROS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide 1: Crear Noche ─────────────────────────────────────────────────────

class _Slide1Night extends StatelessWidget {
  final Animation<double> fade;
  final Size size;
  const _Slide1Night({required this.fade, required this.size});

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      fade: fade,
      title: 'Crea tu noche 🥂',
      subtitle: 'Organiza la salida, invita amigos y juega en grupo',
      visual: _MockNightCard(),
    );
  }
}

class _MockNightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AfterlifeColors.electricPurple.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AfterlifeColors.electricPurple.withValues(alpha: 0.2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.nightlife, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VIERNES ÉPICO',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text('Anfitrión: Unai',
                      style: TextStyle(
                          color: AfterlifeColors.electricPurple, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Avatares
          Row(
            children: [
              ...['U', 'C', 'M', 'A'].map((l) => Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AfterlifeColors.electricPurple, AfterlifeColors.deepPurple],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D0D1A), width: 2),
                    ),
                    child: Center(
                      child: Text(l,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  )),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15), width: 1),
                ),
                child: Center(
                  child: Text('+3',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso jugadores
          Row(
            children: [
              Text('7/10 jugadores',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              const Spacer(),
              const Text('🟢 EN ESPERA',
                  style: TextStyle(
                      color: AfterlifeColors.acidGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AfterlifeColors.electricPurple),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AfterlifeColors.acidGreen, Color(0xFF65A30D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'UNIRSE A LA NOCHE',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide 2: Retos ───────────────────────────────────────────────────────────

class _Slide2Challenges extends StatelessWidget {
  final Animation<double> fade;
  final Size size;
  const _Slide2Challenges({required this.fade, required this.size});

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      fade: fade,
      title: 'Completa retos ⚡',
      subtitle: 'Gana puntos, sube de nivel y desbloquea logros',
      visual: _MockChallenges(),
    );
  }
}

class _MockChallenges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final retos = [
      ('🎤', 'Canta una canción', 50, 0.9, AfterlifeColors.neonPink),
      ('📸', 'Foto grupal', 30, 0.6, AfterlifeColors.cyanBlue),
      ('🕺', 'Baila 30 segundos', 75, 0.3, AfterlifeColors.electricPurple),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: retos.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: r.$5.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Text(r.$1, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.$2,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: r.$4,
                        backgroundColor: Colors.white.withValues(alpha: 0.07),
                        valueColor: AlwaysStoppedAnimation(r.$5),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: r.$5.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${r.$3}',
                  style: TextStyle(
                      color: r.$5,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Slide 3: Minijuegos ──────────────────────────────────────────────────────

class _Slide3Minigames extends StatelessWidget {
  final Animation<double> fade;
  final Size size;
  const _Slide3Minigames({required this.fade, required this.size});

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      fade: fade,
      title: 'Minijuegos 🎮',
      subtitle: 'Calienta el ambiente antes de salir',
      visual: _MockMinigames(),
    );
  }
}

class _MockMinigames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final games = [
      ('🎤', 'Yo Nunca', AfterlifeColors.neonPink),
      ('🍺', 'Verdad o Reto', AfterlifeColors.neonOrange),
      ('🎲', '¿Prefieres?', AfterlifeColors.cyanBlue),
      ('⚡', 'Reto Rápido', AfterlifeColors.acidGreen),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: games.map((g) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: g.$3.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: g.$3.withValues(alpha: 0.1),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(g.$1, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                g.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: g.$3,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Slide 4: Ranking ─────────────────────────────────────────────────────────

class _Slide4Ranking extends StatelessWidget {
  final Animation<double> fade;
  final Size size;
  const _Slide4Ranking({required this.fade, required this.size});

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      fade: fade,
      title: 'Ranking y logros 🏆',
      subtitle: 'Demuestra quién manda en cada noche',
      visual: _MockRanking(),
    );
  }
}

class _MockRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = [
      ('🥇', 'TÚ', 2450, AfterlifeColors.neonOrange, true),
      ('🥈', 'CarlosM', 2100, Colors.white54, false),
      ('🥉', 'Maria99', 1890, Colors.white54, false),
      ('4', 'Juanito', 1540, Colors.white38, false),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Podio visual
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AfterlifeColors.neonOrange.withValues(alpha: 0.15),
                AfterlifeColors.electricPurple.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AfterlifeColors.neonOrange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TÚ ESTÁS EN',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('PUESTO #1',
                      style: TextStyle(
                          color: AfterlifeColors.neonOrange,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ],
              ),
            ],
          ),
        ),
        // Lista
        ...entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: e.$5
                    ? AfterlifeColors.electricPurple.withValues(alpha: 0.12)
                    : const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(12),
                border: e.$5
                    ? Border.all(
                        color:
                            AfterlifeColors.electricPurple.withValues(alpha: 0.4))
                    : null,
              ),
              child: Row(
                children: [
                  Text(e.$1,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e.$2,
                        style: TextStyle(
                            color: e.$5
                                ? AfterlifeColors.electricPurple
                                : Colors.white,
                            fontWeight: e.$5
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 14)),
                  ),
                  Text('${e.$3} pts',
                      style: TextStyle(
                          color: e.$4,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            )),
      ],
    );
  }
}

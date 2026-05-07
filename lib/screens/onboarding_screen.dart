// lib/screens/onboarding_screen.dart
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/screens/how_to_play_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'BIENVENIDO A AFTERLIFE',
      'subtitle': 'Convierte cada salida con amigos en una aventura épica llena de retos, logros y recuerdos inolvidables.',
      'icon': Icons.nightlife,
      'color': AfterlifeColors.electricLilac,
    },
    {
      'title': 'CREA TUS NOCHES',
      'subtitle': 'Organiza salidas, invita a tus amigos y completa retos en tiempo real. Cada noche es única.',
      'icon': Icons.add_circle_outline,
      'color': AfterlifeColors.neonPink,
    },
    {
      'title': 'MINIJUEGOS Y LOGROS',
      'subtitle': 'Juega en la previa, desbloquea logros secretos y demuestra quién es el rey de la noche.',
      'icon': Icons.emoji_events,
      'color': AfterlifeColors.acidGreen,
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 60,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'] as String,
                          style: AfterlifeTextTheme.headlineLarge.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: page['color'] as Color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['subtitle'] as String,
                          style: AfterlifeTextTheme.bodyLarge.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AfterButton(
                label: _currentPage == _pages.length - 1 ? 'EMPEZAR' : 'SIGUIENTE',
                color: AfterlifeColors.electricLilac,
                onPressed: _nextPage,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                );
              },
              child: Text(
                '¿Cómo funciona Afterlife?',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  color: AfterlifeColors.electricPurple,
                  decoration: TextDecoration.underline,
                  decorationColor: AfterlifeColors.electricPurple,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

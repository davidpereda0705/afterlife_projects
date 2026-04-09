import 'package:afterlife_projects/games/truth_or_drinks_game.dart';
import 'package:afterlife_projects/games/would_you_rether_game.dart';
import 'package:afterlife_projects/games/yo_nunca_nunca.dart';
import 'package:afterlife_projects/games/reto_rapido.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';

class MinigamesScreen extends StatelessWidget {
  const MinigamesScreen({super.key});

  final List<Map<String, dynamic>> _games = const [
    // ... tus juegos (igual)
  ];

  void _navigateToGame(BuildContext context, String route) {
    // ... tu navegación (igual)
  }

  @override
  Widget build(BuildContext context) {
    // Eliminamos Scaffold y AppBar
    return Container(
      color: AfterlifeColors.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de bienvenida
          AfterlifeCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREVIA MODE',
                    style: AfterlifeTextTheme.titleSmall.copyWith(
                      color: AfterlifeColors.electricLilac,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige un juego y que empiece el caos',
                    style: AfterlifeTextTheme.bodyLarge.copyWith(
                      color: AfterlifeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Grid de juegos
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _games.length,
            itemBuilder: (context, index) {
              final game = _games[index];
              return GestureDetector(
                onTap: () => _navigateToGame(context, game['route']),
                child: _buildGameCard(
                  title: game['title'],
                  description: game['description'],
                  icon: game['icon'],
                  color: game['color'],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Mensaje de responsabilidad
          AfterlifeCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AfterlifeColors.neonOrange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bebe con responsabilidad. Conoce tus límites y cuida de tus amigos.',
                      style: AfterlifeTextTheme.bodySmall.copyWith(
                        color: AfterlifeColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return AfterlifeCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AfterlifeTextTheme.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AfterlifeTextTheme.bodySmall.copyWith(
              color: AfterlifeColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
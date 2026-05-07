import 'package:afterlife_projects/screens/game_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';

class MinigamesScreen extends StatelessWidget {
  const MinigamesScreen({super.key});

  final List<Map<String, dynamic>> _games = const [
    {
      'title': 'VERDAD O BEBIDA',
      'description': 'Responde con honestidad… o acepta la consecuencia',
      'icon': Icons.psychology_alt_outlined,
      'color': AfterlifeColors.electricPurple,
      'route': 'truth_or_drink',
    },
    {
      'title': 'YO NUNCA',
      'description': 'El juego que destruye amistades',
      'icon': Icons.water_drop_outlined,
      'color': AfterlifeColors.neonPink,
      'route': 'yo_nunca',
    },
    {
      'title': 'RETO RÁPIDO',
      'description': '30 segundos para hacer el ridículo',
      'icon': Icons.timer_outlined,
      'color': AfterlifeColors.cyanBlue,
      'route': 'reto_rapido',
    },
    {
      'title': '¿QUÉ PREFIERES?',
      'description': 'El dilema donde todos pierden',
      'icon': Icons.balance_outlined,
      'color': AfterlifeColors.acidGreen,
      'route': 'would_you_rather',
    },
  ];

  void _navigateToGame(BuildContext context, String route) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameSetupScreen(gameRoute: route)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Eliminamos Scaffold y AppBar
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: AfterlifeColors.electricLilac,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige un juego y que empiece el caos',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                  context: context,
                  title: game['title'],
                  description: game['description'],
                  icon: game['icon'],
                  color: game['color'],
                  isAvailable: true,
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
                  Icon(
                    Icons.info_outline,
                    color: AfterlifeColors.neonOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Juega con responsabilidad. Respeta tus límites y cuida de tus amigos.',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
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
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isAvailable,
  }) {
    return AfterlifeCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
                    
          // Indicador de disponibilidad - ¡AHORA TODOS DISPONIBLES!
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'DISPONIBLE',
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

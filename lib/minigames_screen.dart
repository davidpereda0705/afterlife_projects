// lib/screens/minigames_screen.dart
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
    {
      'title': 'VERDAD O BEBIDA',
      'description': 'Responde con honestidad… o bebe',
      'icon': Icons.psychology_alt_outlined,
      'color': Color(0xFFA855F7),
      'route': 'truth_or_drink',
    },
    {
      'title': 'YO NUNCA',
      'description': 'El juego que destruye amistades',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFFEC4899),
      'route': 'yo_nunca',
    },
    {
      'title': 'RETO RÁPIDO',
      'description': '30 segundos para hacer el ridículo',
      'icon': Icons.timer_outlined,
      'color': Color(0xFF06B6D4),
      'route': 'reto_rapido',
    },
    {
      'title': '¿QUÉ PREFIERES?',
      'description': 'El dilema donde todos pierden',
      'icon': Icons.balance_outlined,
      'color': Color(0xFF84CC16),
      'route': 'would_you_rather', // Cambiado el identificador
    },
  ];

  void _navigateToGame(BuildContext context, String route) {
    switch (route) {
      case 'truth_or_drink':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TruthOrDrinkGame()),
        );
        break;
      case 'yo_nunca':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YoNuncaGame()),
        );
        break;
      case 'reto_rapido':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RetoRapidoGame()),
        );
        break;
      case 'would_you_rather': // ¡NUEVO CASO!
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WouldYouRatherGame()),
        );
        break;
      default:
        // Para cualquier otro juego no implementado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Próximamente! Este juego llegará muy pronto...'),
            backgroundColor: AfterlifeColors.electricPurple,
            duration: const Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Minijuegos',
          style: AfterlifeTextTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AfterlifeAvatar(
              initials: 'CR',
              status: AvatarStatus.online,
              size: 40,
              showStatusIndicator: true,
            ),
          ),
        ],
      ),
      body: ListView(
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
                  isAvailable: game['route'] != 'would_you_rather' ? true : true, // ¡AHORA SÍ DISPONIBLE!
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
    required bool isAvailable, // Nuevo parámetro
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
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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
          
          // Indicador de disponibilidad - ¡AHORA TODOS DISPONIBLES!
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
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
        ],
      ),
    );
  }
}
// lib/screens/minigames_screen.dart
import 'package:afterlife_projects/games/yo_nunca_nunca.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
// IMPORTANTE: Asegúrate de crear este archivo para el juego

class MinigamesScreen extends StatelessWidget {
  const MinigamesScreen({super.key});

  final List<Map<String, dynamic>> _games = const [
    {
      'title': 'VERDAD O BEBIDA',
      'description': 'Responde con honestidad… o bebe',
      'icon': Icons.psychology_alt_outlined,
      'color': Color(0xFFA855F7),
    },
    {
      'title': 'YO NUNCA',
      'description': 'El juego que destruye amistades',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'title': 'RETO RÁPIDO',
      'description': '30 segundos para hacer el ridículo',
      'icon': Icons.timer_outlined,
      'color': Color(0xFF06B6D4),
    },
    {
      'title': '¿QUÉ PREFIERES?',
      'description': 'El dilema donde todos pierden',
      'icon': Icons.balance_outlined,
      'color': Color(0xFF84CC16),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Minijuegos',
          // Usamos copyWith sobre headlineMedium que sí lo tienes en tu código
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
        child: Column(
          children: [
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

            Expanded(
              child: GridView.builder(
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
                  // Añadimos la navegación al pulsar la tarjeta
                  return GestureDetector(
                    onTap: () {
                      if (game['title'] == 'YO NUNCA') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const YoNuncaGame(),
                          ),
                        );
                      } else {
                        // Feedback visual para juegos no implementados
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${game['title']} llegará pronto...'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: _buildGameCard(
                      title: game['title'],
                      description: game['description'],
                      icon: game['icon'],
                      color: game['color'],
                    ),
                  );
                },
              ),
            ),
            itemCount: _games.length,
            itemBuilder: (context, index) {
              final game = _games[index];
              return _buildGameCard(
                title: game['title'],
                description: game['description'],
                icon: game['icon'],
                color: game['color'],
              );
            },
          ),

          const SizedBox(height: 16),

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
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
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
        ],
      ),
    );
  }
}
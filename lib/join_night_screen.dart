// lib/screens/join_night_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'night_game_screen.dart'; // 👈 IMPORTANTE: importar la pantalla de juego

class JoinNightScreen extends StatefulWidget {
  const JoinNightScreen({super.key});

  @override
  State<JoinNightScreen> createState() => _JoinNightScreenState();
}

class _JoinNightScreenState extends State<JoinNightScreen> {
  // Noches disponibles
  final List<Map<String, dynamic>> _availableNights = [
    {
      'id': '1',
      'hostName': 'Ana',
      'hostInitials': 'AN',
      'nightName': 'Viernes de Locura',
      'groupName': 'Los Desvelados',
      'day': 'Viernes',
      'time': '22:30',
      'currentPlayers': 3,
      'maxPlayers': 8,
      'players': [
        {'name': 'Ana', 'initials': 'AN', 'points': 0},
        {'name': 'María', 'initials': 'MJ', 'points': 0},
        {'name': 'Luis', 'initials': 'LM', 'points': 0},
      ],
      'challenges': [
        {'name': 'Selfie con el grupo', 'points': 100, 'completed': false},
        {'name': 'Baila con un extraño', 'points': 150, 'completed': false},
        {'name': 'Foto con el DJ', 'points': 120, 'completed': false},
      ],
    },
    {
      'id': '2',
      'hostName': 'Carlos',
      'hostInitials': 'CR',
      'nightName': 'Sábado Nocturno',
      'groupName': 'Fiesteros Nocturnos',
      'day': 'Sábado',
      'time': '23:00',
      'currentPlayers': 2,
      'maxPlayers': 6,
      'players': [
        {'name': 'Carlos', 'initials': 'CR', 'points': 0},
        {'name': 'Pablo', 'initials': 'PA', 'points': 0},
      ],
      'challenges': [
        {'name': 'Selfie con el grupo', 'points': 100, 'completed': false},
        {'name': 'Baila con un extraño', 'points': 150, 'completed': false},
      ],
    },
    {
      'id': '3',
      'hostName': 'María',
      'hostInitials': 'MJ',
      'nightName': 'Previa del Viernes',
      'groupName': 'Party Animals',
      'day': 'Viernes',
      'time': '21:00',
      'currentPlayers': 4,
      'maxPlayers': 4,
      'players': [
        {'name': 'María', 'initials': 'MJ', 'points': 0},
        {'name': 'Luis', 'initials': 'LT', 'points': 0},
        {'name': 'Marta', 'initials': 'MS', 'points': 0},
        {'name': 'Javier', 'initials': 'JV', 'points': 0},
      ],
      'challenges': [
        {'name': 'Selfie con el grupo', 'points': 100, 'completed': false},
        {'name': 'Baila con un extraño', 'points': 150, 'completed': false},
        {'name': 'Foto con el DJ', 'points': 120, 'completed': false},
        {'name': 'Canta una canción', 'points': 200, 'completed': false},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Unirse a Noche',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NOCHES DISPONIBLES',
              style: TextStyle(
                color: Color(0xFFEC4899),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: _availableNights.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _availableNights.length,
                      itemBuilder: (context, index) {
                        return _buildNightCard(_availableNights[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNightCard(Map<String, dynamic> night) {
    final bool isFull = night['currentPlayers'] >= night['maxPlayers'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull 
              ? Colors.grey.withOpacity(0.3)
              : const Color(0xFFEC4899).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    night['hostInitials'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      night['nightName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${night['hostName']} · ${night['groupName']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                '${night['day']} · ${night['time']}',
                style: const TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              if (!isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF84CC16).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DISPONIBLE',
                    style: TextStyle(
                      color: Color(0xFF84CC16),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'COMPLETA',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.people, color: Colors.white54, size: 18),
              const SizedBox(width: 4),
              Text(
                '${night['currentPlayers']}/${night['maxPlayers']}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFull ? null : () => _joinNight(night),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull 
                    ? Colors.grey.withOpacity(0.3)
                    : const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isFull ? 'COMPLETA' : 'UNIRSE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlight_round,
            size: 60,
            color: const Color(0xFF7B1FA2).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay noches disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea una nueva noche o vuelve más tarde',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // Función para unirse a la noche (MODIFICADA)
  void _joinNight(Map<String, dynamic> night) {
    // Añadir al usuario actual a la lista de jugadores
    List<Map<String, dynamic>> updatedPlayers = List.from(night['players'] ?? []);
    updatedPlayers.add({'name': 'TÚ', 'initials': 'TU', 'points': 0});
    
    // Crear copia actualizada de la noche
    Map<String, dynamic> updatedNight = Map.from(night);
    updatedNight['players'] = updatedPlayers;
    updatedNight['currentPlayers'] = (night['currentPlayers'] ?? 0) + 1;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has unido a ${night['nightName']}'),
        backgroundColor: const Color(0xFF84CC16),
        duration: const Duration(milliseconds: 500),
      ),
    );
    
    // IR DIRECTAMENTE A LA SALA DE JUEGO
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NightGameScreen(nightData: updatedNight),
        ),
      );
    });
  }
}
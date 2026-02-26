// lib/screens/create_night_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'night_game_screen.dart'; // 👈 IMPORTANTE: importar la pantalla de juego

class CreateNightScreen extends StatefulWidget {
  const CreateNightScreen({super.key});

  @override
  State<CreateNightScreen> createState() => _CreateNightScreenState();
}

class _CreateNightScreenState extends State<CreateNightScreen> {
  // Controladores
  final TextEditingController _nightNameController = TextEditingController();
  final TextEditingController _challengeNameController = TextEditingController();
  final TextEditingController _challengePointsController = TextEditingController();
  
  // Variables
  String? _selectedDay;
  String? _selectedHour;
  int _maxPlayers = 8;
  
  // Días de la semana
  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  
  // Horas de inicio
  final List<String> _hours = [
    '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', 
    '23:00', '23:30', '00:00', '00:30', '01:00', '01:30', 
    '02:00', '02:30', '03:00', '03:30', '04:00'
  ];
  
  // Lista de retos personalizados
  final List<Map<String, dynamic>> _customChallenges = [];

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
          'Crear Noche',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Título
            const Center(
              child: Text(
                'NUEVA NOCHE',
                style: TextStyle(
                  color: Color(0xFF7B1FA2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 1. Nombre de la noche
            _buildLabel('NOMBRE DE LA NOCHE', const Color(0xFF7B1FA2)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nightNameController,
              hint: 'Ej: Viernes de Locura',
              icon: Icons.nightlife,
              color: const Color(0xFF7B1FA2),
            ),
            
            const SizedBox(height: 25),
            
            // 2. DÍA Y HORA
            _buildLabel('CUÁNDO EMPIEZA', const Color(0xFF06B6D4)),
            const SizedBox(height: 8),
            _buildDayTimeSelector(),
            
            const SizedBox(height: 25),
            
            // 3. Total de jugadores
            _buildLabel('TOTAL DE JUGADORES', const Color(0xFFEC4899)),
            const SizedBox(height: 8),
            _buildPlayersSlider(),
            
            const SizedBox(height: 25),
            
            // 4. Crear retos personalizados
            _buildLabel('CREA TUS RETOS', const Color(0xFF06B6D4)),
            const SizedBox(height: 8),
            _buildCreateChallengeCard(),
            
            const SizedBox(height: 20),
            
            // 5. Lista de retos creados
            if (_customChallenges.isNotEmpty) ...[
              _buildLabel('RETOS CREADOS (${_customChallenges.length})', const Color(0xFF84CC16)),
              const SizedBox(height: 8),
              _buildChallengesList(),
            ],
            
            const SizedBox(height: 30),
            
            // 6. Botón crear noche
            _buildCreateButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget para las etiquetas
  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  // Widget para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Selector de día y hora
  Widget _buildDayTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Selector de día
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDay,
              hint: const Text(
                'Día',
                style: TextStyle(color: Colors.white54),
              ),
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF06B6D4)),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: _days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value;
                });
              },
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Selector de hora
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedHour,
              hint: const Text(
                'Hora',
                style: TextStyle(color: Colors.white54),
              ),
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(Icons.access_time, color: Color(0xFF06B6D4), size: 20),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: _hours.map((hour) {
                return DropdownMenuItem(
                  value: hour,
                  child: Text(hour),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHour = value;
                });
              },
            ),
          ),
          
          // Tooltip informativo
          const SizedBox(width: 8),
          const Tooltip(
            message: 'Hora de inicio. La noche termina cuando queráis',
            child: Icon(Icons.info_outline, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }

  // Widget para slider de jugadores
  Widget _buildPlayersSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jugadores:',
                style: TextStyle(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_maxPlayers',
                  style: const TextStyle(
                    color: Color(0xFFEC4899),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPlayers.toDouble(),
            min: 2,
            max: 20,
            divisions: 18,
            activeColor: const Color(0xFFEC4899),
            inactiveColor: const Color(0xFFEC4899).withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _maxPlayers = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget para crear retos
  Widget _buildCreateChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Campo nombre del reto
          Row(
            children: [
              const Icon(Icons.add_task, color: Color(0xFF06B6D4), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _challengeNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ej: Selfie con el grupo',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          
          const Divider(color: Colors.white10, height: 16),
          
          // Campo puntos y botón
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _challengePointsController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Puntos (ej: 100)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addCustomChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('AÑADIR'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para lista de retos creados
  Widget _buildChallengesList() {
    return Column(
      children: _customChallenges.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> challenge = entry.value;
        return _buildChallengeTile(challenge, index);
      }).toList(),
    );
  }

  // Widget para cada reto creado
  Widget _buildChallengeTile(Map<String, dynamic> challenge, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF84CC16).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF84CC16).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFF84CC16),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${challenge['points']} pts',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _customChallenges.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget para botón crear noche
  Widget _buildCreateButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _createNight,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'CREAR NOCHE',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (_customChallenges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_customChallenges.length} retos personalizados',
              style: TextStyle(
                color: const Color(0xFF84CC16),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // Función para añadir reto personalizado
  void _addCustomChallenge() {
    String name = _challengeNameController.text.trim();
    String pointsText = _challengePointsController.text.trim();

    if (name.isEmpty) {
      _showMessage('Escribe un nombre para el reto', const Color(0xFFF59E0B));
      return;
    }

    int points = int.tryParse(pointsText) ?? 0;
    if (points <= 0) {
      _showMessage('Pon puntos válidos (ej: 100)', const Color(0xFFF59E0B));
      return;
    }

    setState(() {
      _customChallenges.add({
        'name': name,
        'points': points,
      });
      _challengeNameController.clear();
      _challengePointsController.clear();
    });
  }

  // Función para crear la noche (MODIFICADA)
  void _createNight() {
    if (_nightNameController.text.isEmpty) {
      _showMessage('Pon un nombre a la noche', const Color(0xFFF59E0B));
      return;
    }

    if (_selectedDay == null) {
      _showMessage('Selecciona el día', const Color(0xFFF59E0B));
      return;
    }

    if (_selectedHour == null) {
      _showMessage('Selecciona la hora', const Color(0xFFF59E0B));
      return;
    }

    if (_customChallenges.isEmpty) {
      _showMessage('Crea al menos 1 reto personalizado', const Color(0xFFF59E0B));
      return;
    }

    // Crear objeto de la nueva noche (DATOS DE PRUEBA)
    Map<String, dynamic> newNight = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nightNameController.text,
      'hostName': 'TÚ',
      'hostInitials': 'TU',
      'groupName': 'Mi Grupo',
      'day': _selectedDay,
      'time': _selectedHour,
      'players': [
        {'name': 'TÚ', 'initials': 'TU', 'points': 0},
      ],
      'challenges': _customChallenges.map((c) {
        return {
          'name': c['name'],
          'points': c['points'],
          'completed': false,
        };
      }).toList(),
    };

    _showMessage('¡Noche creada con éxito!', const Color(0xFF84CC16));
    
    // IR DIRECTAMENTE A LA SALA DE JUEGO
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NightGameScreen(nightData: newNight),
        ),
      );
    });
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _nightNameController.dispose();
    _challengeNameController.dispose();
    _challengePointsController.dispose();
    super.dispose();
  }
}
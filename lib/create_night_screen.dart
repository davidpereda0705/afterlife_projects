// lib/screens/create_night_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';
import '../services/night_service.dart';
import '../services/achievement_service.dart';
import '../providers/user_provider.dart';
import '../theme/colors.dart';
import '../data/challenge_bank.dart';
import 'night_game_screen.dart';

class CreateNightScreen extends StatefulWidget {
  const CreateNightScreen({super.key});

  @override
  State<CreateNightScreen> createState() => _CreateNightScreenState();
}

class _CreateNightScreenState extends State<CreateNightScreen> {
  final NightService _nightService = NightService();
  final AchievementService _achievementService = AchievementService();

  final TextEditingController _nightNameController = TextEditingController();
  final TextEditingController _challengeNameController = TextEditingController();
  final TextEditingController _challengePointsController = TextEditingController();

  String? _selectedDay;
  String? _selectedHour;
  int _maxPlayers = 8;

  final List<String> _days = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  final List<String> _hours = [
    '20:00', '20:30', '21:00', '21:30', '22:00', '22:30',
    '23:00', '23:30', '00:00', '00:30', '01:00', '01:30',
    '02:00', '02:30', '03:00', '03:30', '04:00'
  ];

  final List<Map<String, dynamic>> _customChallenges = [];
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
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
            const Center(
              child: Text(
                'NUEVA NOCHE',
                style: TextStyle(
                  color: AfterlifeColors.electricLilac,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel('NOMBRE DE LA NOCHE', AfterlifeColors.electricLilac),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nightNameController,
              hint: 'Ej: Viernes de Locura',
              icon: Icons.nightlife,
              color: AfterlifeColors.electricLilac,
            ),
            const SizedBox(height: 25),

            _buildLabel('CUÁNDO EMPIEZA', AfterlifeColors.cyanBlue),
            const SizedBox(height: 8),
            _buildDayTimeSelector(),
            const SizedBox(height: 25),

            _buildLabel('TOTAL DE JUGADORES', AfterlifeColors.neonPink),
            const SizedBox(height: 8),
            _buildPlayersSlider(),
            const SizedBox(height: 25),

            _buildLabel('CREA TUS RETOS', AfterlifeColors.cyanBlue),
            const SizedBox(height: 8),
            _buildCategoryChips(),
            const SizedBox(height: 12),
            _buildCreateChallengeCard(),
            const SizedBox(height: 20),

            if (_customChallenges.isNotEmpty) ...[
              _buildLabel('RETOS CREADOS (${_customChallenges.length})', AfterlifeColors.acidGreen),
              const SizedBox(height: 8),
              _buildChallengesList(),
            ],
            const SizedBox(height: 30),

            _buildCreateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  Widget _buildDayTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AfterlifeColors.cyanBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDay,
              hint: const Text('Día', style: TextStyle(color: Colors.white54)),
              dropdownColor: AfterlifeColors.surfaceDark,
              icon: const Icon(Icons.arrow_drop_down, color: AfterlifeColors.cyanBlue),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
              items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (value) => setState(() => _selectedDay = value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedHour,
              hint: const Text('Hora', style: TextStyle(color: Colors.white54)),
              dropdownColor: AfterlifeColors.surfaceDark,
              icon: const Icon(Icons.access_time, color: AfterlifeColors.cyanBlue, size: 20),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
              items: _hours.map((hour) => DropdownMenuItem(value: hour, child: Text(hour))).toList(),
              onChanged: (value) => setState(() => _selectedHour = value),
            ),
          ),
          const SizedBox(width: 8),
          const Tooltip(
            message: 'Hora de inicio. La noche termina cuando queráis',
            child: Icon(Icons.info_outline, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AfterlifeColors.neonPink.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jugadores:', style: TextStyle(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AfterlifeColors.neonPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_maxPlayers', style: const TextStyle(color: AfterlifeColors.neonPink, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          Slider(
            value: _maxPlayers.toDouble(),
            min: 2,
            max: 20,
            divisions: 18,
            activeColor: AfterlifeColors.neonPink,
            inactiveColor: AfterlifeColors.neonPink.withOpacity(0.2),
            onChanged: (value) => setState(() => _maxPlayers = value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AfterlifeColors.cyanBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.add_task, color: AfterlifeColors.cyanBlue, size: 20),
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
          Row(
            children: [
              const Icon(Icons.star, color: AfterlifeColors.neonOrange, size: 20),
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
                  backgroundColor: AfterlifeColors.cyanBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('AÑADIR'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList() {
    return Column(
      children: _customChallenges.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> challenge = entry.value;
        return _buildChallengeTile(challenge, index);
      }).toList(),
    );
  }

  Widget _buildChallengeTile(Map<String, dynamic> challenge, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AfterlifeColors.acidGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AfterlifeColors.acidGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emoji_events, color: AfterlifeColors.acidGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AfterlifeColors.neonOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('${challenge['points']} pts', style: const TextStyle(color: AfterlifeColors.neonOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => setState(() => _customChallenges.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isCreating ? null : _createNight,
          style: ElevatedButton.styleFrom(
            backgroundColor: AfterlifeColors.electricLilac,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isCreating
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('CREAR NOCHE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        if (_customChallenges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${_customChallenges.length} retos personalizados', style: TextStyle(color: AfterlifeColors.acidGreen, fontSize: 12)),
          ),
      ],
    );
  }

  void _addCustomChallenge() {
    String name = _challengeNameController.text.trim();
    String pointsText = _challengePointsController.text.trim();

    if (name.isEmpty) {
      _showMessage('Escribe un nombre para el reto', AfterlifeColors.neonOrange);
      return;
    }
    int points = int.tryParse(pointsText) ?? 0;
    if (points <= 0) {
      _showMessage('Pon puntos válidos (ej: 100)', AfterlifeColors.neonOrange);
      return;
    }
    setState(() {
      _customChallenges.add({'name': name, 'points': points, 'type': ChallengeType.individual});
      _challengeNameController.clear();
      _challengePointsController.clear();
    });
  }

  void _addSuggestedChallenges(ChallengeType? type) {
    final suggestions = type != null
        ? ChallengeBank.getByType(type)
        : ChallengeBank.all;
    final random = List<Challenge>.from(suggestions)..shuffle();
    final selected = random.take(3).toList();
    for (final c in selected) {
      if (!_customChallenges.any((existing) => existing['name'] == c.name)) {
        _customChallenges.add({'name': c.name, 'points': c.points, 'type': c.type});
      }
    }
    setState(() {});
  }

  Widget _buildCategoryChips() {
    final categories = [
      {'label': 'Aleatorio', 'type': null, 'color': AfterlifeColors.electricLilac},
      {'label': 'Grupal', 'type': ChallengeType.group, 'color': AfterlifeColors.acidGreen},
      {'label': 'Individual', 'type': ChallengeType.individual, 'color': AfterlifeColors.cyanBlue},
      {'label': 'Competitivo', 'type': ChallengeType.competitive, 'color': AfterlifeColors.neonOrange},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        return ActionChip(
          backgroundColor: (cat['color'] as Color).withOpacity(0.15),
          side: BorderSide(color: (cat['color'] as Color).withOpacity(0.4)),
          label: Text(
            cat['label'] as String,
            style: TextStyle(color: cat['color'] as Color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          onPressed: () => _addSuggestedChallenges(cat['type'] as ChallengeType?),
        );
      }).toList(),
    );
  }

  Future<void> _createNight() async {
    // Validaciones
    if (_nightNameController.text.trim().isEmpty) {
      _showMessage('Pon un nombre a la noche', AfterlifeColors.neonOrange);
      return;
    }
    if (_selectedDay == null) {
      _showMessage('Selecciona el día', AfterlifeColors.neonOrange);
      return;
    }
    if (_selectedHour == null) {
      _showMessage('Selecciona la hora', AfterlifeColors.neonOrange);
      return;
    }
    if (_customChallenges.isEmpty) {
      _addSuggestedChallenges(null);
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showMessage('Debes iniciar sesión', Colors.red);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.userData?['username'] ?? 'Anfitrión';
    final initials = username.length >= 2 ? username.substring(0, 2).toUpperCase() : username.substring(0, 1).toUpperCase();

    setState(() => _isCreating = true);

    try {
      final nightId = await _nightService.createNight(
        name: _nightNameController.text.trim(),
        hostId: userId,
        hostName: username,
        hostInitials: initials,
        groupName: 'Mi Grupo',  // Puedes hacer editable después
        day: _selectedDay!,
        time: _selectedHour!,
        maxPlayers: _maxPlayers,
        challenges: _customChallenges.map((c) => {
          'name': c['name'],
          'points': c['points'],
          'completed': false,
          'completedBy': null,
        }).toList(),
      );

      // Marcar la noche como activa para el usuario
      await _nightService.setActiveNightForUser(userId, nightId);

      // ✅ INCREMENTAR NIGHTS CREATED Y VERIFICAR LOGROS
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();
      final currentNightsCreated = userDoc.data()?['nightsCreated'] ?? 0;
      await userDocRef.update({'nightsCreated': currentNightsCreated + 1});

      // Refrescar UserProvider para tener los datos actualizados
      await userProvider.refresh();

      // Obtener estadísticas actualizadas para verificar logros
      final updatedData = userProvider.userData;
      final nightsCompleted = updatedData?['nightsCompleted'] ?? 0;
      final challengesCompleted = updatedData?['challengesCompleted'] ?? 0;
      final level = updatedData?['level'] ?? 1;
      final friendsCount = updatedData?['friendsCount'] ?? 0;
      final photosUploaded = updatedData?['photosUploaded'] ?? 0;
      final newNightsCreated = currentNightsCreated + 1;

      final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
        userId: userId,
        nightsCompleted: nightsCompleted,
        challengesCompleted: challengesCompleted,
        level: level,
        friendsCount: friendsCount,
        photosUploaded: photosUploaded,
        nightsCreated: newNightsCreated,
      );

      if (newlyUnlocked.isNotEmpty && mounted) {
        final achievementNames = newlyUnlocked.map((a) => a.title).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ¡Logros desbloqueados: $achievementNames!'),
            backgroundColor: AfterlifeColors.acidGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        await userProvider.refresh(); // Refrescar de nuevo para mostrar los nuevos logros
      }

      _showMessage('¡Noche creada con éxito!', AfterlifeColors.acidGreen);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NightGameScreen(nightId: nightId),
          ),
        );
      }
    } catch (e) {
      _showMessage('Error al crear la noche: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
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
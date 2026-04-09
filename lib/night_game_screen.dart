// lib/screens/night_game_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:afterlife_projects/journal_storage.dart';
import 'package:afterlife_projects/night_summary.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';
import '../components/AfterLife_Avatar.dart';
import 'complete_challenge_screen.dart';
import 'night_summary_screen.dart';
import 'ActiveNightManager.dart';

enum AvatarStatus { online, offline, inNight }

class NightGameScreen extends StatefulWidget {
  final Map<String, dynamic> nightData;

  const NightGameScreen({super.key, required this.nightData});

  @override
  State<NightGameScreen> createState() => _NightGameScreenState();
}

class _NightGameScreenState extends State<NightGameScreen> {
  int _currentChallengeIndex = 0;
  late Map<String, dynamic> _nightData;

  late DateTime _startTime;
  late DateTime _endTime;
  Duration _timeLeft = Duration.zero;
  Timer? _timer;
  bool _canFinish = false;
  bool _isFinishing = false; // 👈 Evita múltiples finalizaciones

  @override
  void initState() {
    super.initState();
    _nightData = widget.nightData.isNotEmpty
        ? widget.nightData
        : _getMockNightData();

    if (_nightData['nightPhotos'] == null) {
      _nightData['nightPhotos'] = <Uint8List>[];
    }

    ActiveNightManager().setActiveNight(_nightData);

    _startTime = _parseStartTime();
    _endTime = _calculateEndTime(_startTime);
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  DateTime _parseStartTime() {
    final now = DateTime.now();
    final timeStr = _nightData['time'] ?? '22:30';
    final parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  DateTime _calculateEndTime(DateTime start) {
    DateTime end = DateTime(start.year, start.month, start.day, 6, 0);
    if (start.hour >= 6) {
      end = end.add(const Duration(days: 1));
    }
    return end;
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    if (now.isAfter(_endTime)) {
      if (!_isFinishing) {
        setState(() {
          _timeLeft = Duration.zero;
          _canFinish = true;
        });
        _timer?.cancel();
        // 👈 Finalizar automáticamente al llegar la hora
        _finishNight();
      }
    } else {
      setState(() {
        _timeLeft = _endTime.difference(now);
      });
    }
  }

  Map<String, dynamic> _getMockNightData() {
    return {
      'id': '1',
      'name': 'Viernes de Locura',
      'hostName': 'Ana',
      'hostInitials': 'AN',
      'groupName': 'Los Desvelados',
      'day': 'Viernes',
      'time': '22:30',
      'players': [
        {'name': 'Ana', 'initials': 'AN', 'points': 450},
        {'name': 'Carlos', 'initials': 'CR', 'points': 380},
        {'name': 'María', 'initials': 'MJ', 'points': 520},
        {'name': 'Luis', 'initials': 'LP', 'points': 290},
      ],
      'challenges': [
        {'name': 'Selfie con el grupo', 'points': 100, 'completed': false},
        {'name': 'Baila con un extraño', 'points': 150, 'completed': false},
        {'name': 'Foto con el DJ', 'points': 120, 'completed': true},
        {'name': 'Canta una canción', 'points': 200, 'completed': false},
        {'name': 'Haz reír a todos', 'points': 130, 'completed': false},
      ],
      'nightPhotos': <Uint8List>[],
    };
  }

  Future<void> _addNightPhoto() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          (_nightData['nightPhotos'] as List).add(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _saveToJournal() {
    try {
      final id = _nightData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final name = _nightData['name'] ?? 'Noche sin nombre';
      final day = _nightData['day'] ?? '';
      final time = _nightData['time'] ?? '';
      final groupName = _nightData['groupName'] ?? '';

      final playersCopy = List<Map<String, dynamic>>.from(_nightData['players'] ?? []);
      final challengesCopy = (_nightData['challenges'] as List? ?? []).map((c) {
        final copy = Map<String, dynamic>.from(c);
        if (copy['proofBytes'] != null) {
          copy['proofBytes'] = Uint8List.fromList(copy['proofBytes']);
        }
        return copy;
      }).toList();
      final nightPhotosCopy = List<Uint8List>.from(_nightData['nightPhotos'] ?? []);

      final entry = NightSummary(
        id: id,
        name: name,
        day: day,
        time: time,
        groupName: groupName,
        players: playersCopy,
        challenges: challengesCopy,
        nightPhotos: nightPhotosCopy,
        timestamp: DateTime.now(),
      );
      JournalStorage().saveEntry(entry);
      print('Resumen guardado correctamente');
    } catch (e) {
      print('Error guardando resumen: $e');
    }
  }

  void _finishNight() {
    if (_isFinishing) return;
    _isFinishing = true;
    _saveToJournal();
    ActiveNightManager().clearActiveNight();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NightSummaryScreen(nightData: _nightData),
      ),
    );
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _nightData['name'] ?? 'Noche',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_nightData['day'] ?? ''} · ${_nightData['time'] ?? ''} · ${_nightData['groupName'] ?? ''}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7B1FA2).withOpacity(0.3),
              ),
            ),
            child: Text(
              _formatDuration(_timeLeft),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flag, color: Color(0xFF84CC16)),
            onPressed: _finishNight,
          ),
          IconButton(
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            onPressed: _addNightPhoto,
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7B1FA2).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_getTotalPoints()} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHostInfo(),
                const SizedBox(height: 20),
                _buildCurrentChallenge(),
                const SizedBox(height: 20),
                _buildNightPhotos(),
                const SizedBox(height: 20),
                _buildPlayersRanking(),
                const SizedBox(height: 20),
                _buildChallengesList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final challenges = _nightData['challenges'] ?? [];
    int total = challenges.length;
    int completed = challenges.where((c) => c['completed'] == true).length;
    double progress = total > 0 ? completed / total : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Text('$completed/$total', style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFEC4899)),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7B1FA2).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFEC4899)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(_nightData['hostInitials'] ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ANFITRIÓN', style: TextStyle(color: Color(0xFF7B1FA2), fontSize: 10, fontWeight: FontWeight.bold)),
                Text(_nightData['hostName'] ?? 'Anfitrión', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF84CC16).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('EN CURSO', style: TextStyle(color: Color(0xFF84CC16), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentChallenge() {
    final challenges = _nightData['challenges'] ?? [];
    final bool allCompleted = _currentChallengeIndex >= challenges.length || challenges.every((c) => c['completed'] == true);
    if (allCompleted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFEC4899)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF7B1FA2).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              '¡RETOS COMPLETADOS!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Puedes finalizar la noche cuando quieras',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (challenges.isEmpty || _currentChallengeIndex >= challenges.length) return const SizedBox();
    final current = challenges[_currentChallengeIndex];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFEC4899)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF7B1FA2).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text('RETO ACTUAL', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(current['name'] ?? 'Reto', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('${current['points'] ?? 0} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNightPhotos() {
    final photos = _nightData['nightPhotos'] as List? ?? [];
    if (photos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('FOTOS DE LA NOCHE', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1))),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) => Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(image: MemoryImage(photos[index]), fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlayersRanking() {
    final players = List<Map<String, dynamic>>.from(_nightData['players'] ?? [])..sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));
    if (players.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CLASIFICACIÓN', style: TextStyle(color: Color(0xFFEC4899), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...List.generate(players.length, (index) {
          final player = players[index];
          final isHost = player['name'] == _nightData['hostName'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: index == 0 ? const Color(0xFFF59E0B).withOpacity(0.5) : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: index == 0 ? const Color(0xFFF59E0B).withOpacity(0.2) : Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text('${index + 1}', style: TextStyle(color: index == 0 ? const Color(0xFFF59E0B) : Colors.white54, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(player['initials'] ?? '?', style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(player['name'] ?? 'Jugador', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      if (isHost) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF7B1FA2).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('HOST', style: TextStyle(color: Color(0xFF7B1FA2), fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('${player['points'] ?? 0} pts', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChallengesList() {
    final challenges = _nightData['challenges'] ?? [];
    if (challenges.isEmpty) return const SizedBox();
    final allCompleted = challenges.every((c) => c['completed'] == true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RETOS', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...List.generate(challenges.length, (index) {
          final challenge = challenges[index];
          final isCurrent = index == _currentChallengeIndex && !allCompleted;
          final isCompleted = challenge['completed'] == true;
          return GestureDetector(
            onTap: allCompleted ? null : () {
              setState(() => _currentChallengeIndex = index);
              _navigateToCompleteChallenge(challenge);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF06B6D4) : isCompleted ? const Color(0xFF84CC16).withOpacity(0.3) : Colors.transparent,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: isCompleted ? const Color(0xFF84CC16).withOpacity(0.2) : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isCompleted ? Icons.check_circle : Icons.emoji_events, color: isCompleted ? const Color(0xFF84CC16) : Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(challenge['name'] ?? 'Reto',
                        style: TextStyle(color: isCompleted ? Colors.white.withOpacity(0.6) : Colors.white, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  ),
                  if (challenge['proof'] != null) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.image, color: Colors.white54, size: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isCompleted ? const Color(0xFF84CC16).withOpacity(0.2) : const Color(0xFFF59E0B).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('${challenge['points'] ?? 0} pts', style: TextStyle(color: isCompleted ? const Color(0xFF84CC16) : const Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _navigateToCompleteChallenge(Map<String, dynamic> challenge) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompleteChallengeScreen(challenge: challenge, players: _nightData['players'])),
    );
    if (result != null) _completeChallengeWithData(result['player'], result['image']);
  }

  void _completeChallengeWithData(String playerName, Uint8List? imageBytes) {
    setState(() {
      final challenge = _nightData['challenges'][_currentChallengeIndex];
      challenge['completed'] = true;
      challenge['completedBy'] = playerName;
      if (imageBytes != null) challenge['proofBytes'] = imageBytes;
      int points = challenge['points'] ?? 0;
      for (var player in _nightData['players']) {
        if (player['name'] == playerName) {
          player['points'] = (player['points'] ?? 0) + points;
          break;
        }
      }
      int nextIndex = _currentChallengeIndex + 1;
      while (nextIndex < _nightData['challenges'].length && _nightData['challenges'][nextIndex]['completed'] == true) {
        nextIndex++;
      }
      if (nextIndex < _nightData['challenges'].length) {
        _currentChallengeIndex = nextIndex;
      } else {
        _currentChallengeIndex = _nightData['challenges'].length;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Has completado todos los retos! Finaliza la noche cuando quieras.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _getTotalPoints() {
    int total = 0;
    for (var player in _nightData['players'] ?? []) {
      total += (player['points'] is int ? player['points'] as int : int.tryParse(player['points'].toString()) ?? 0);
    }
    return total;
  }
}
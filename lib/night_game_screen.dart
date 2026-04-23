// lib/screens/night_game_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/night_service.dart';
import '../services/achievement_service.dart';
import '../providers/user_provider.dart';
import 'complete_challenge_screen.dart';
import 'night_summary_screen.dart';

class NightGameScreen extends StatefulWidget {
  final String nightId;

  const NightGameScreen({super.key, required this.nightId});

  @override
  State<NightGameScreen> createState() => _NightGameScreenState();
}

class _NightGameScreenState extends State<NightGameScreen> {
  final NightService _nightService = NightService();
  final AchievementService _achievementService = AchievementService();
  late Stream<Map<String, dynamic>?> _nightStream;
  int _currentChallengeIndex = 0;
  bool _isFinishing = false;

  String? _currentUserId;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _nightStream = _nightService.streamNight(widget.nightId);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _currentUsername = userProvider.userData?['username'];
    });
  }

  DateTime _parseStartTime(String timeStr) {
    final now = DateTime.now();
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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _addNightPhoto(String nightId) async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        await _nightService.addNightPhoto(nightId, bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto añadida'), backgroundColor: AfterlifeColors.acidGreen),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  int _getCurrentUserPoints(Map<String, dynamic> nightData) {
    if (_currentUsername == null) return 0;
    final players = nightData['players'] as List? ?? [];
    for (var player in players) {
      if (player['name'] == _currentUsername) {
        return player['points'] as int? ?? 0;
      }
    }
    return 0;
  }

  int _getCompletedChallengesCount(Map<String, dynamic> nightData) {
    final challenges = nightData['challenges'] as List? ?? [];
    return challenges.where((c) => c['completed'] == true).length;
  }

  Future<void> _finishNight(String nightId, Map<String, dynamic> nightData) async {
    if (_isFinishing) return;
    _isFinishing = true;

    try {
      await _nightService.finishNight(nightId);

      if (_currentUserId != null) {
        await _nightService.clearActiveNightForUser(_currentUserId!);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refresh();
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final pointsEarned = _getCurrentUserPoints(nightData);
      final completedChallenges = _getCompletedChallengesCount(nightData);

      await userProvider.updateAfterNight(
        pointsEarned: pointsEarned,
        nightsCompletedIncrement: 1,
        challengesCompletedIncrement: completedChallenges,
      );

      // Verificar logros después de actualizar estadísticas
      final updatedUserData = userProvider.userData;
      final nightsCompleted = updatedUserData?['nightsCompleted'] ?? 0;
      final challengesCompletedTotal = updatedUserData?['challengesCompleted'] ?? 0;
      final level = updatedUserData?['level'] ?? 0;
      final friendsCount = updatedUserData?['friendsCount'] ?? 0;
      final photosUploaded = updatedUserData?['photosUploaded'] ?? 0;
      final nightsCreated = updatedUserData?['nightsCreated'] ?? 0;

      final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
        userId: _currentUserId!,
        nightsCompleted: nightsCompleted,
        challengesCompleted: challengesCompletedTotal,
        level: level,
        friendsCount: friendsCount,
        photosUploaded: photosUploaded,
        nightsCreated: nightsCreated,
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
        await userProvider.refresh();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NightSummaryScreen(nightData: nightData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al finalizar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isFinishing = false;
    }
  }

  void _navigateToCompleteChallenge(Map<String, dynamic> challenge, String nightId, List<dynamic> playersRaw) async {
    final List<Map<String, dynamic>> players = List<Map<String, dynamic>>.from(playersRaw);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteChallengeScreen(
          challenge: challenge,
          players: players,
        ),
      ),
    );
    if (result != null && mounted) {
      final playerName = result['player'];
      final imageBytes = result['image'] as Uint8List?;
      
      // Completar el reto (esto suma puntos al jugador y marca el reto como completado)
      await _nightService.completeChallenge(
        nightId,
        _currentChallengeIndex,
        playerName,
        imageBytes,
      );

      // Si se subió una foto, incrementar photosUploaded y verificar logros
      if (imageBytes != null && _currentUserId != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUserId);
        final userDoc = await userDocRef.get();
        final currentPhotos = userDoc.data()?['photosUploaded'] ?? 0;
        await userDocRef.update({'photosUploaded': currentPhotos + 1});
        
        // Refrescar para obtener los nuevos datos
        await userProvider.refresh();
        
        // Obtener estadísticas actualizadas
        final updatedData = userProvider.userData;
        final nightsCompleted = updatedData?['nightsCompleted'] ?? 0;
        final challengesCompletedTotal = updatedData?['challengesCompleted'] ?? 0;
        final level = updatedData?['level'] ?? 0;
        final friendsCount = updatedData?['friendsCount'] ?? 0;
        final photosUploaded = currentPhotos + 1;
        final nightsCreated = updatedData?['nightsCreated'] ?? 0;
        
        // Verificar logros
        final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
          userId: _currentUserId!,
          nightsCompleted: nightsCompleted,
          challengesCompleted: challengesCompletedTotal,
          level: level,
          friendsCount: friendsCount,
          photosUploaded: photosUploaded,
          nightsCreated: nightsCreated,
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
          await userProvider.refresh();
        }
      }
      
      // El StreamBuilder actualizará la UI automáticamente
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _nightStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white))),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(child: Text('Noche no encontrada', style: TextStyle(color: Colors.white))),
          );
        }

        final nightData = snapshot.data!;
        final challenges = nightData['challenges'] as List? ?? [];
        final players = nightData['players'] as List? ?? [];
        final nightPhotos = nightData['nightPhotos'] as List? ?? [];

        int totalChallenges = challenges.length;
        int completedChallenges = challenges.where((c) => c['completed'] == true).length;
        double progress = totalChallenges > 0 ? completedChallenges / totalChallenges : 0;

        int nextIncompleteIndex = challenges.indexWhere((c) => c['completed'] != true);
        if (nextIncompleteIndex == -1) nextIncompleteIndex = challenges.length;
        if (_currentChallengeIndex != nextIncompleteIndex && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentChallengeIndex = nextIncompleteIndex);
          });
        }

        final allCompleted = completedChallenges == totalChallenges && totalChallenges > 0;
        final startTime = _parseStartTime(nightData['time'] ?? '22:30');
        final endTime = _calculateEndTime(startTime);
        final now = DateTime.now();
        final timeLeft = endTime.isAfter(now) ? endTime.difference(now) : Duration.zero;
        int totalPoints = 0;
        for (var player in players) {
          totalPoints += (player['points'] as int? ?? 0);
        }

        return Scaffold(
          backgroundColor: AfterlifeColors.background,
          appBar: AppBar(
            backgroundColor: AfterlifeColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nightData['name'] ?? 'Noche',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${nightData['day'] ?? ''} · ${nightData['time'] ?? ''} · ${nightData['groupName'] ?? ''}',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AfterlifeColors.electricLilac.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
                ),
                child: Text(_formatDuration(timeLeft), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
              IconButton(
                icon: const Icon(Icons.flag, color: AfterlifeColors.acidGreen),
                onPressed: () => _finishNight(widget.nightId, nightData),
              ),
              IconButton(
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                onPressed: () => _addNightPhoto(widget.nightId),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AfterlifeColors.electricLilac.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AfterlifeColors.neonOrange, size: 16),
                    const SizedBox(width: 4),
                    Text('$totalPoints pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AfterlifeColors.surfaceDark,
                child: Row(
                  children: [
                    Text('$completedChallenges/$totalChallenges', style: const TextStyle(color: AfterlifeColors.neonPink, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(AfterlifeColors.neonPink),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHostInfo(nightData),
                    const SizedBox(height: 20),
                    _buildCurrentChallenge(nightData, _currentChallengeIndex, allCompleted),
                    const SizedBox(height: 20),
                    _buildNightPhotos(nightPhotos),
                    const SizedBox(height: 20),
                    _buildPlayersRanking(players, nightData['hostName']),
                    const SizedBox(height: 20),
                    _buildChallengesList(challenges, _currentChallengeIndex, allCompleted, widget.nightId, players),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHostInfo(Map<String, dynamic> nightData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AfterlifeColors.electricLilac, AfterlifeColors.neonPink]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(nightData['hostInitials'] ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ANFITRIÓN', style: TextStyle(color: AfterlifeColors.electricLilac, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(nightData['hostName'] ?? 'Anfitrión', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AfterlifeColors.acidGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('EN CURSO', style: TextStyle(color: AfterlifeColors.acidGreen, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentChallenge(Map<String, dynamic> nightData, int currentIndex, bool allCompleted) {
    final challenges = nightData['challenges'] as List? ?? [];
    if (allCompleted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AfterlifeColors.electricLilac, AfterlifeColors.neonPink]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AfterlifeColors.electricLilac.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text('¡RETOS COMPLETADOS!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Puedes finalizar la noche cuando quieras', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    if (challenges.isEmpty || currentIndex >= challenges.length) return const SizedBox();
    final current = challenges[currentIndex];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AfterlifeColors.electricLilac, AfterlifeColors.neonPink]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AfterlifeColors.electricLilac.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.emoji_events, color: Colors.white, size: 24), SizedBox(width: 8), Text('RETO ACTUAL', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))]),
          const SizedBox(height: 12),
          Text(current['name'] ?? 'Reto', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text('${current['points'] ?? 0} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
        ],
      ),
    );
  }

  Widget _buildNightPhotos(List photos) {
    if (photos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('FOTOS DE LA NOCHE', style: TextStyle(color: AfterlifeColors.cyanBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1))),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              ImageProvider imageProvider;
              if (photo is String) {
                imageProvider = NetworkImage(photo);
              } else if (photo is Uint8List) {
                imageProvider = MemoryImage(photo);
              } else if (photo is List<int>) {
                imageProvider = MemoryImage(Uint8List.fromList(photo));
              } else {
                imageProvider = const AssetImage('assets/placeholder.png');
              }
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlayersRanking(List<dynamic> players, String? hostName) {
    if (players.isEmpty) return const SizedBox();
    final sorted = List<Map<String, dynamic>>.from(players)..sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CLASIFICACIÓN', style: TextStyle(color: AfterlifeColors.neonPink, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...List.generate(sorted.length, (index) {
          final player = sorted[index];
          final isHost = player['name'] == hostName;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: index == 0 ? AfterlifeColors.neonOrange.withOpacity(0.5) : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: index == 0 ? AfterlifeColors.neonOrange.withOpacity(0.2) : Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text('${index + 1}', style: TextStyle(color: index == 0 ? AfterlifeColors.neonOrange : Colors.white54, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AfterlifeColors.cyanBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(player['initials'] ?? '?', style: const TextStyle(color: AfterlifeColors.cyanBlue, fontWeight: FontWeight.bold))),
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
                          decoration: BoxDecoration(color: AfterlifeColors.electricLilac.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('HOST', style: TextStyle(color: AfterlifeColors.electricLilac, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AfterlifeColors.neonOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('${player['points'] ?? 0} pts', style: const TextStyle(color: AfterlifeColors.neonOrange, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChallengesList(List<dynamic> challenges, int currentIndex, bool allCompleted, String nightId, List<dynamic> players) {
    if (challenges.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RETOS', style: TextStyle(color: AfterlifeColors.cyanBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...List.generate(challenges.length, (index) {
          final challenge = challenges[index];
          final isCurrent = index == currentIndex && !allCompleted;
          final isCompleted = challenge['completed'] == true;
          return GestureDetector(
            onTap: allCompleted ? null : () {
              if (!isCompleted) _navigateToCompleteChallenge(challenge, nightId, players);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCurrent ? AfterlifeColors.cyanBlue : isCompleted ? AfterlifeColors.acidGreen.withOpacity(0.3) : Colors.transparent, width: isCurrent ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: isCompleted ? AfterlifeColors.acidGreen.withOpacity(0.2) : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isCompleted ? Icons.check_circle : Icons.emoji_events, color: isCompleted ? AfterlifeColors.acidGreen : Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(challenge['name'] ?? 'Reto', style: TextStyle(color: isCompleted ? Colors.white.withOpacity(0.6) : Colors.white, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal))),
                  if (challenge['proofBytes'] != null) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.image, color: Colors.white54, size: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isCompleted ? AfterlifeColors.acidGreen.withOpacity(0.2) : AfterlifeColors.neonOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('${challenge['points'] ?? 0} pts', style: TextStyle(color: isCompleted ? AfterlifeColors.acidGreen : AfterlifeColors.neonOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
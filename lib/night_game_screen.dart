// lib/screens/night_game_screen.dart
import 'dart:async';
import 'package:afterlife_projects/components/challenge_wheel.dart';
import 'package:afterlife_projects/components/expense_splitter.dart';
import 'package:afterlife_projects/components/moments_viewer.dart';
import 'package:afterlife_projects/components/night_chat_sheet.dart';
import 'package:afterlife_projects/components/spotify_link.dart';
import 'package:afterlife_projects/services/offline_service.dart';
import 'package:afterlife_projects/night_summary.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/night_service.dart';
import '../services/achievement_service.dart';
import '../services/journal_service.dart';
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
  final JournalService _journalService = JournalService();
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
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return now;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return now;
    }
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

  // ✅ ÚNICA MODIFICACIÓN: compresión de la imagen
  Future<void> _addNightPhoto(String nightId) async {
    HapticFeedback.mediumImpact();
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,        // reducido de 80 a 60
        maxWidth: 800,           // añadido
        maxHeight: 800,          // añadido
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        await _nightService.addNightPhoto(nightId, bytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto añadida'), backgroundColor: AfterlifeColors.acidGreen),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
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

  // Convierte cualquier tipo de lista a Uint8List para evitar errores de tipo
  Uint8List _toUint8List(dynamic data) {
    if (data == null) return Uint8List(0);
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    if (data is List<dynamic>) {
      try {
        return Uint8List.fromList(data.cast<int>().toList());
      } catch (e) {
        return Uint8List(0);
      }
    }
    return Uint8List(0);
  }

  Future<void> _finishNight(String nightId, Map<String, dynamic> nightData) async {
    HapticFeedback.heavyImpact();
    if (_isFinishing) return;
    _isFinishing = true;

    // --------------------------------------------------------------
    // 1. Guardar el diario (independiente del resto)
    // --------------------------------------------------------------
    debugPrint('🔵 [DIARIO] Iniciando guardado...');
    try {
      if (_currentUserId == null) {
        debugPrint('❌ [DIARIO] Usuario no autenticado');
      } else {
        final rawNightPhotos = nightData['nightPhotos'] as List? ?? [];
        final convertedNightPhotos = rawNightPhotos.map((p) => _toUint8List(p)).toList();

        final rawChallenges = nightData['challenges'] as List? ?? [];
        final convertedChallenges = rawChallenges.map((c) {
          final copy = Map<String, dynamic>.from(c);
          if (copy['proofBytes'] != null) {
            copy['proofBytes'] = _toUint8List(copy['proofBytes']).toList();
          }
          return copy;
        }).toList();

        final summary = NightSummary(
          id: nightId,
          name: nightData['name'] ?? '',
          day: nightData['day'] ?? '',
          time: nightData['time'] ?? '',
          groupName: nightData['groupName'] ?? '',
          players: List<Map<String, dynamic>>.from(nightData['players'] ?? []),
          challenges: convertedChallenges,
          nightPhotos: convertedNightPhotos,
          timestamp: DateTime.now(),
        );
        await _journalService.saveEntry(summary);
        debugPrint('✅ [DIARIO] Resumen guardado correctamente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Noche guardada en el diario'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e, stack) {
      debugPrint('❌ [DIARIO] Error guardando resumen: $e\n$stack');
    }

    // --------------------------------------------------------------
    // 2. Operaciones de finalización de noche
    // --------------------------------------------------------------
    try {
      await _nightService.finishNight(nightId);

      final currentUserId = _currentUserId;
      if (currentUserId != null) {
        await _nightService.clearActiveNightForUser(currentUserId);
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refresh();
      }

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final pointsEarned = _getCurrentUserPoints(nightData);
      final completedChallenges = _getCompletedChallengesCount(nightData);

      await userProvider.updateAfterNight(
        pointsEarned: pointsEarned,
        nightsCompletedIncrement: 1,
        challengesCompletedIncrement: completedChallenges,
      );

      final updatedUserData = userProvider.userData;
      final nightsCompleted = updatedUserData?['nightsCompleted'] ?? 0;
      final challengesCompletedTotal = updatedUserData?['challengesCompleted'] ?? 0;
      final level = updatedUserData?['level'] ?? 0;
      final friendsCount = updatedUserData?['friendsCount'] ?? 0;
      final photosUploaded = updatedUserData?['photosUploaded'] ?? 0;
      final nightsCreated = updatedUserData?['nightsCreated'] ?? 0;

      final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
        userId: currentUserId ?? '',
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
          SnackBar(content: Text('Error al finalizar: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      _isFinishing = false;
    }
  }

  void _navigateToCompleteChallenge(Map<String, dynamic> challenge, String nightId, List<dynamic> playersRaw) async {
    HapticFeedback.lightImpact();
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

      await _nightService.completeChallenge(
        nightId,
        _currentChallengeIndex,
        playerName,
        imageBytes,
      );

      if (imageBytes != null && _currentUserId != null) {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUserId);
        final userDoc = await userDocRef.get();
        final currentPhotos = userDoc.data()?['photosUploaded'] ?? 0;
        await userDocRef.update({'photosUploaded': currentPhotos + 1});
        await userProvider.refresh();

        final updatedData = userProvider.userData;
        final nightsCompleted = updatedData?['nightsCompleted'] ?? 0;
        final challengesCompletedTotal = updatedData?['challengesCompleted'] ?? 0;
        final level = updatedData?['level'] ?? 0;
        final friendsCount = updatedData?['friendsCount'] ?? 0;
        final photosUploaded = currentPhotos + 1;
        final nightsCreated = updatedData?['nightsCreated'] ?? 0;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _nightStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          // Modo offline: intentar cargar desde cache
          return FutureBuilder<Map<String, dynamic>?>(
            future: OfflineService.getCachedActiveNight(),
            builder: (ctx, cacheSnap) {
              if (cacheSnap.hasData && cacheSnap.data != null) {
                return _buildNightUI(cacheSnap.data!, true);
              }
              return Scaffold(
                body: Center(child: Text('Noche no encontrada', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
              );
            },
          );
        }

        // Cachear noche para modo offline
        OfflineService.cacheActiveNight(snapshot.data!);

        return _buildNightUI(snapshot.data!, false);
      },
    );
  }

  Widget _buildNightUI(Map<String, dynamic> nightData, bool isOffline) {
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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nightData['name'] ?? 'Noche',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${nightData['day'] ?? ''} · ${nightData['time'] ?? ''} · ${nightData['groupName'] ?? ''} ${isOffline ? "(offline)" : ""}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AfterlifeColors.electricLilac.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3)),
            ),
            child: Text(_formatDuration(timeLeft), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: AfterlifeColors.acidGreen),
            tooltip: 'Chat del grupo',
            onPressed: () => _showNightChat(nightData),
          ),
          IconButton(
            icon: const Icon(Icons.flag, color: AfterlifeColors.acidGreen),
            onPressed: () => _finishNight(widget.nightId, nightData),
          ),
          IconButton(
            icon: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _addNightPhoto(widget.nightId),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AfterlifeColors.electricLilac.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AfterlifeColors.neonOrange, size: 16),
                const SizedBox(width: 4),
                Text('$totalPoints pts', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Text('$completedChallenges/$totalChallenges', style: const TextStyle(color: AfterlifeColors.neonPink, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
                const SizedBox(height: 12),
                MomentsViewer(nightId: widget.nightId, nightName: nightData['name'] ?? 'Noche'),
                const SizedBox(height: 20),
                _buildPlayersRanking(players, nightData['hostName']),
                const SizedBox(height: 8),
                _buildDriverToggle(players),
                const SizedBox(height: 20),
                _buildChallengesList(challenges, _currentChallengeIndex, allCompleted, widget.nightId, players),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MÉTODOS DE CONSTRUCCIÓN DE UI ====================
  Widget _buildHostInfo(Map<String, dynamic> nightData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3)),
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
            child: Center(child: Text(nightData['hostInitials'] ?? '?', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ANFITRIÓN', style: TextStyle(color: AfterlifeColors.electricLilac, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(nightData['hostName'] ?? 'Anfitrión', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AfterlifeColors.acidGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
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
          boxShadow: [BoxShadow(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Theme.of(context).colorScheme.onPrimary, size: 48),
            const SizedBox(height: 16),
            Text('¡RETOS COMPLETADOS!', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Puedes finalizar la noche cuando quieras', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)), textAlign: TextAlign.center),
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
        boxShadow: [BoxShadow(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.onPrimary, size: 24), const SizedBox(width: 8), Text('RETO ACTUAL', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))]),
          const SizedBox(height: 12),
          Text(current['name'] ?? 'Reto', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text('${current['points'] ?? 0} pts', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)))]),
        ],
      ),
    );
  }

  Widget _buildNightPhotos(List photos) {
    final urls = photos.whereType<String>().toList();
    if (urls.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('FOTOS DE LA NOCHE', style: TextStyle(color: AfterlifeColors.cyanBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1))),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: NetworkImage(urls[index]), fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDriverToggle(List<dynamic> players) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return const SizedBox();
    final me = players.cast<Map<String, dynamic>>().firstWhere(
      (p) => (p['userId'] ?? '') == currentUserId,
      orElse: () => {},
    );
    if (me.isEmpty) return const SizedBox();
    final isDriver = me['isDesignatedDriver'] == true;
    return GestureDetector(
      onTap: () => _toggleDriver(currentUserId, !isDriver),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDriver ? AfterlifeColors.acidGreen.withValues(alpha: 0.1) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDriver ? AfterlifeColors.acidGreen.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDriver ? Icons.local_taxi : Icons.local_taxi_outlined,
              size: 18,
              color: isDriver ? AfterlifeColors.acidGreen : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 8),
            Text(
              isDriver ? 'Eres conductor designado (+50 pts al final)' : 'Marcarme como conductor designado',
              style: TextStyle(
                fontSize: 12,
                color: isDriver ? AfterlifeColors.acidGreen : Theme.of(context).disabledColor,
                fontWeight: isDriver ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersRanking(List<dynamic> players, String? hostName) {
    if (players.isEmpty) return const SizedBox();
    final sorted = List<Map<String, dynamic>>.from(players)..sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));

    // Medal emojis and pod styling for top 3
    const medals = ['🥇', '🥈', '🥉'];
    final podiumBg = [
      const Color(0xFFF59E0B), // gold
      const Color(0xFF94A3B8), // silver
      const Color(0xFFCD7F32), // bronze
    ];
    final podiumBorder = [
      AfterlifeColors.neonOrange,
      const Color(0xFF94A3B8),
      const Color(0xFFCD7F32),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AfterlifeColors.neonPink, AfterlifeColors.electricPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.leaderboard, color: AfterlifeColors.neonPink, size: 16),
            const SizedBox(width: 6),
            const Text(
              'CLASIFICACION',
              style: TextStyle(color: AfterlifeColors.neonPink, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(sorted.length, (index) {
          final player = sorted[index];
          final isHost = player['name'] == hostName;
          final isCurrentUser = player['name'] == _currentUsername;
          final isTop3 = index < 3;
          final medal = isTop3 ? medals[index] : null;
          final bgColor = isTop3 ? podiumBg[index].withValues(alpha: 0.08) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025);
          final borderColor = isCurrentUser
              ? AfterlifeColors.electricPurple.withValues(alpha: 0.7)
              : isTop3
                  ? podiumBorder[index].withValues(alpha: 0.45)
                  : Colors.transparent;
          final borderWidth = isCurrentUser ? 2.0 : isTop3 ? 1.5 : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isCurrentUser
                  ? [BoxShadow(color: AfterlifeColors.electricPurple.withValues(alpha: 0.25), blurRadius: 8)]
                  : isTop3
                      ? [BoxShadow(color: podiumBorder[index].withValues(alpha: 0.15), blurRadius: 6)]
                      : [],
            ),
            child: Row(
              children: [
                // Medal or rank number
                SizedBox(
                  width: 36,
                  child: medal != null
                      ? Text(medal, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center)
                      : Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                // Avatar initials
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? AfterlifeColors.electricPurple.withValues(alpha: 0.25)
                        : AfterlifeColors.cyanBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrentUser
                        ? Border.all(color: AfterlifeColors.electricPurple.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      player['initials'] ?? '?',
                      style: TextStyle(
                        color: isCurrentUser ? AfterlifeColors.electricPurple : AfterlifeColors.cyanBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + badges
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          player['name'] ?? 'Jugador',
                          style: TextStyle(
                            color: isCurrentUser
                                ? AfterlifeColors.electricPurple
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (player['isDesignatedDriver'] == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.local_taxi, size: 14, color: AfterlifeColors.acidGreen),
                        ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AfterlifeColors.electricPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('TU', style: TextStyle(color: AfterlifeColors.electricPurple, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      if (isHost) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AfterlifeColors.electricLilac.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('HOST', style: TextStyle(color: AfterlifeColors.electricLilac, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                // Points
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isTop3
                        ? podiumBorder[index].withValues(alpha: 0.15)
                        : AfterlifeColors.neonOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${player['points'] ?? 0} pts',
                    style: TextStyle(
                      color: isTop3 ? podiumBorder[index] : AfterlifeColors.neonOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCurrent ? AfterlifeColors.cyanBlue : isCompleted ? AfterlifeColors.acidGreen.withValues(alpha: 0.3) : Colors.transparent, width: isCurrent ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: isCompleted ? AfterlifeColors.acidGreen.withValues(alpha: 0.2) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isCompleted ? Icons.check_circle : Icons.emoji_events, color: isCompleted ? AfterlifeColors.acidGreen : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(challenge['name'] ?? 'Reto', style: TextStyle(color: isCompleted ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6) : Theme.of(context).colorScheme.onSurface, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal))),
                  if (challenge['proofBytes'] != null) Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isCompleted ? AfterlifeColors.acidGreen.withValues(alpha: 0.2) : AfterlifeColors.neonOrange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
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


  void _showSpotifySheet(Map<String, dynamic> nightData) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpotifyLinkSheet(
        currentUrl: nightData['spotifyUrl'],
        onUrlChanged: (url) async {
          try {
            await _nightService.updateSpotifyUrl(widget.nightId, url);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
              );
            }
          }
        },
      ),
    );
  }

  void _showNightChat(Map<String, dynamic> nightData) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NightChatSheet(
        nightId: widget.nightId,
        senderName: _currentUsername ?? 'Usuario',
      ),
    );
  }


  void _showChallengeWheel(List<dynamic> players) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Ruleta del destino', textAlign: TextAlign.center),
        content: ChallengeWheel(players: List<Map<String, dynamic>>.from(players)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  void _showExpenseSheet(List<dynamic> players, List<dynamic>? expenses) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: ExpenseSplitter(
              players: List<Map<String, dynamic>>.from(players),
              existingExpenses: expenses != null ? List<Map<String, dynamic>>.from(expenses) : null,
              onExpensesChanged: (newExpenses) async {
                try {
                  await _nightService.updateExpenses(widget.nightId, newExpenses);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error guardando gastos: $e'), backgroundColor: Theme.of(context).colorScheme.error),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleDriver(String userId, bool isDriver) async {
    HapticFeedback.mediumImpact();
    try {
      await _nightService.toggleDesignatedDriver(widget.nightId, userId, isDriver);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
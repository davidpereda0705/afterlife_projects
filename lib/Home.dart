// lib/features/home/home_screen.dart
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart' as avatar;
import 'package:afterlife_projects/create_night_screen.dart';
import 'package:afterlife_projects/night_game_screen.dart';
import 'package:afterlife_projects/services/night_service.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../AchievementsScreen.dart'; // Ajusta la ruta si es necesario

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToNights; // Añadido
  const HomeScreen({super.key, this.onNavigateToNights});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NightService _nightService = NightService();
  final AchievementService _achievementService = AchievementService();
  List<Map<String, dynamic>> _availableNights = [];
  bool _isLoadingNights = true;
  String? _errorNights;

  List<Map<String, dynamic>> _upcomingAchievements = [];
  bool _isLoadingAchievements = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableNights();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    if (!userProvider.isLoading) {
      _loadAchievements(userProvider.userData);
    }
  }

  Future<void> _loadAvailableNights() async {
    setState(() {
      _isLoadingNights = true;
      _errorNights = null;
    });
    try {
      final nights = await _nightService.getAvailableNights();
      setState(() {
        _availableNights = nights;
        _isLoadingNights = false;
      });
    } catch (e) {
      setState(() {
        _errorNights = e.toString();
        _isLoadingNights = false;
      });
    }
  }

  Future<void> _loadAchievements(Map<String, dynamic>? userData) async {
    if (userData == null) return;
    setState(() => _isLoadingAchievements = true);
    try {
      final allAchievements = await _achievementService.getAllAchievements();
      final nightsCompleted = userData['nightsCompleted'] ?? 0;
      final challengesCompleted = userData['challengesCompleted'] ?? 0;
      final level = userData['level'] ?? 1;
      final friendsCount = userData['friendsCount'] ?? 0;
      final photosUploaded = userData['photosUploaded'] ?? 0;
      final nightsCreated = userData['nightsCreated'] ?? 0;

      List<Map<String, dynamic>> achievementsWithProgress = [];
      for (final ach in allAchievements) {
        final progress = _achievementService.getProgress(
          ach,
          nightsCompleted: nightsCompleted,
          challengesCompleted: challengesCompleted,
          level: level,
          friendsCount: friendsCount,
          photosUploaded: photosUploaded,
          nightsCreated: nightsCreated,
        );
        if (progress < 1.0) {
          achievementsWithProgress.add({
            'title': ach.title,
            'icon': ach.icon,
            'progress': progress,
          });
        }
      }

      achievementsWithProgress.sort((a, b) {
        final progressA = (a['progress'] as double?) ?? 0.0;
        final progressB = (b['progress'] as double?) ?? 0.0;
        return progressB.compareTo(progressA);
      });
      final topThree = achievementsWithProgress.take(3).toList();

      setState(() {
        _upcomingAchievements = topThree;
        _isLoadingAchievements = false;
      });
    } catch (e) {
      setState(() => _isLoadingAchievements = false);
      debugPrint('Error cargando logros: $e');
    }
  }

  Future<void> _joinNight(Map<String, dynamic> night) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('Debes iniciar sesión', Colors.red);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.activeNightId != null) {
      _showSnackBar('Ya tienes una noche activa', Colors.orange);
      return;
    }

    final username = userProvider.userData?['username'] ?? 'Usuario';
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.substring(0, 1).toUpperCase();

    try {
      final nightDoc = await _nightService.getNightById(night['id']);
      if (nightDoc == null) {
        _showSnackBar('La noche ya no existe', Colors.red);
        _loadAvailableNights();
        return;
      }

      final currentPlayers = (nightDoc['players'] as List? ?? []).length;
      final maxPlayers = nightDoc['maxPlayers'] ?? 0;
      if (currentPlayers >= maxPlayers) {
        _showSnackBar('La noche está llena', Colors.red);
        _loadAvailableNights();
        return;
      }

      await _nightService.joinNight(night['id'], userId, username, initials);
      await _nightService.setActiveNightForUser(userId, night['id']);
      await userProvider.refresh();

      _showSnackBar('Te has unido a ${night['name']}', AfterlifeColors.acidGreen);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NightGameScreen(nightId: night['id']),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error al unirse: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (userProvider.error != null) {
          return Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar perfil: ${userProvider.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final userData = userProvider.userData;
        final userName = userData?['username'] ?? 'Usuario';
        final userLevel = userData?['level'] ?? 1;
        final nightsCompleted = userData?['nightsCompleted'] ?? 0;
        final challengesCompleted = userData?['challengesCompleted'] ?? 0;
        final groupsCount = userData?['friendsCount'] ?? 0;

        return Scaffold(
          backgroundColor: AfterlifeColors.background,
          body: RefreshIndicator(
            onRefresh: _loadAvailableNights,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileCard(
                  userName,
                  userLevel,
                  nightsCompleted,
                  challengesCompleted,
                  groupsCount,
                ),
                const SizedBox(height: 24),
                _buildPendingNightsSection(context),
                const SizedBox(height: 16),
                _buildCreateNightButton(context, userProvider),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(
    String userName,
    int userLevel,
    int nightsCompleted,
    int challengesCompleted,
    int groupsCount,
  ) {
    return AfterlifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              avatar.AfterlifeAvatar(
                initials: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                status: avatar.AvatarStatus.online,
                size: 70,
                showStatusIndicator: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.electricLilac.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
                      ),
                      child: Text(
                        'NIVEL $userLevel',
                        style: AfterlifeTextTheme.labelSmall.copyWith(
                          color: AfterlifeColors.electricLilac,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                value: nightsCompleted.toString(),
                label: 'Noches',
                icon: Icons.nightlight_round,
                color: AfterlifeColors.neonPink,
              ),
              _buildStatColumn(
                value: challengesCompleted.toString(),
                label: 'Retos',
                icon: Icons.emoji_events,
                color: AfterlifeColors.cyanBlue,
              ),
              _buildStatColumn(
                value: groupsCount.toString(),
                label: 'Grupos',
                icon: Icons.group,
                color: AfterlifeColors.acidGreen,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'PRÓXIMOS LOGROS',
            style: AfterlifeTextTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildAchievementsRow(),
        ],
      ),
    );
  }

  Widget _buildAchievementsRow() {
    if (_isLoadingAchievements) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_upcomingAchievements.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Completa más acciones para desbloquear logros',
            style: TextStyle(color: AfterlifeColors.textSecondary),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _upcomingAchievements.map((achievement) {
        return GestureDetector(
          onTap: () {
            // Navegación a la pantalla de logros con resaltado
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AchievementsScreen(
                  highlightTitle: achievement['title'],
                ),
              ),
            );
          },
          child: _buildAchievementProgress(
            icon: achievement['icon'],
            title: achievement['title'],
            progress: achievement['progress'],
          ),
        );
      }).toList(),
    );
  }

  // ===== SECCIÓN DE NOCHES EN ESPERA =====
  Widget _buildPendingNightsSection(BuildContext context) {
    if (_isLoadingNights) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorNights != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AfterlifeColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              'Error al cargar noches: $_errorNights',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAvailableNights,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_availableNights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AfterlifeColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.nightlight_round,
              color: AfterlifeColors.electricLilac.withOpacity(0.5),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay noches en espera',
              style: AfterlifeTextTheme.bodyLarge.copyWith(
                color: AfterlifeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea una nueva noche o espera a que tus amigos te inviten',
              textAlign: TextAlign.center,
              style: AfterlifeTextTheme.bodySmall.copyWith(
                color: AfterlifeColors.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AfterlifeColors.neonOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.nightlight_round, color: AfterlifeColors.neonOrange, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'NOCHES EN ESPERA (${_availableNights.length})',
                style: AfterlifeTextTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AfterlifeColors.neonOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: _availableNights.map((night) => _buildNightCard(context, night)).toList(),
        ),
      ],
    );
  }

  Widget _buildNightCard(BuildContext context, Map<String, dynamic> night) {
    final players = night['players'] as List? ?? [];
    final currentPlayers = players.length;
    final maxPlayers = night['maxPlayers'] ?? 0;
    final bool isFull = currentPlayers >= maxPlayers;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AfterlifeColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AfterlifeColors.neonOrange.withOpacity(0.3), width: 1.5),
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
                  gradient: AfterlifeColors.electricLilacGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.group, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      night['groupName'] ?? 'Grupo',
                      style: AfterlifeTextTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, color: AfterlifeColors.neonOrange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Anfitrión: ${night['hostName'] ?? ''}',
                          style: AfterlifeTextTheme.bodySmall.copyWith(color: AfterlifeColors.neonOrange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AfterlifeColors.neonOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  night['time'] ?? '',
                  style: AfterlifeTextTheme.labelSmall.copyWith(
                    color: AfterlifeColors.neonOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.nightlife, color: AfterlifeColors.neonOrange, size: 16),
              const SizedBox(width: 8),
              Text(
                night['name'] ?? 'Noche sin nombre',
                style: AfterlifeTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jugadores: $currentPlayers/$maxPlayers',
                style: AfterlifeTextTheme.bodySmall.copyWith(color: AfterlifeColors.textSecondary),
              ),
              if (!isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.acidGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PLAZAS DISPONIBLES',
                    style: AfterlifeTextTheme.labelSmall.copyWith(
                      color: AfterlifeColors.acidGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFull ? null : () => _joinNight(night),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull ? Colors.grey.withOpacity(0.3) : AfterlifeColors.neonOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isFull ? 'NOCHE COMPLETA' : 'UNIRSE A LA NOCHE',
                style: AfterlifeTextTheme.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNightButton(BuildContext context, UserProvider userProvider) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (userProvider.activeNightId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ya tienes una noche activa. Finalízala antes de crear una nueva.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNightScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AfterlifeColors.electricLilac,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            const SizedBox(width: 8),
            Text(
              'CREAR NUEVA NOCHE',
              style: AfterlifeTextTheme.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AfterlifeTextTheme.titleMedium.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: AfterlifeTextTheme.labelSmall.copyWith(color: AfterlifeColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAchievementProgress({
    required IconData icon,
    required String title,
    required double progress,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3), width: 2),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AfterlifeColors.electricLilac),
                strokeWidth: 3,
              ),
            ),
            Icon(icon, color: AfterlifeColors.electricLilac.withOpacity(0.8), size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: AfterlifeTextTheme.labelSmall.copyWith(color: AfterlifeColors.textSecondary)),
        Text('${(progress * 100).toInt()}%', style: AfterlifeTextTheme.labelSmall.copyWith(color: AfterlifeColors.electricLilac, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
// lib/features/home/home_screen.dart
import 'package:afterlife_projects/widgets/common/afterlife_avatar.dart' as avatar;
import 'package:afterlife_projects/widgets/effects/animated_entry.dart';
import 'package:afterlife_projects/widgets/effects/glass_card.dart';
import 'package:afterlife_projects/widgets/effects/neon_border.dart';
import 'package:afterlife_projects/widgets/effects/shimmer_loading.dart';
import 'package:afterlife_projects/widgets/effects/confetti_blast.dart';
import 'package:afterlife_projects/screens/nights/create_night_screen.dart';
import 'package:afterlife_projects/screens/nights/night_game_screen.dart';
import 'package:afterlife_projects/services/night_service.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:afterlife_projects/services/ranking_service.dart';
import 'package:afterlife_projects/screens/minigames/minigames_screen.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'package:afterlife_projects/screens/achievements/achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToNights;
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
  bool _achievementsLoadedOnce = false;

  Future<List<UserRankData>>? _rankingFuture;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadAvailableNights();
    _rankingFuture = RankingService().getFriendsRanking(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      sortBy: 'points',
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_achievementsLoadedOnce) return;
    final userProvider = Provider.of<UserProvider>(context);
    if (!userProvider.isLoading) {
      _achievementsLoadedOnce = true;
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
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 6, itemHeight: 100),
            ),
          );
        }
        if (userProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar perfil: ${userProvider.error}',
                    style: TextStyle(color: textPrimary),
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

        final compact = context.read<SettingsProvider>().compactMode;
        return ConfettiBlast(
          controller: _confettiController,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: _loadAvailableNights,
              color: AfterlifeColors.electricPurple,
              backgroundColor: isDark ? const Color(0xFF1A0533) : Colors.white,
              child: ListView(
                padding: EdgeInsets.all(compact ? 10 : 16),
                children: [
                  AnimatedEntry(
                    child: _buildProfileCard(
                      userName,
                      userLevel,
                      nightsCompleted,
                      challengesCompleted,
                      groupsCount,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 100),
                    child: _buildMiniRankingCard(),
                  ),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 150),
                    child: _buildMinigamesCard(context),
                  ),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 200),
                    child: _buildMotivationalCard(nightsCompleted),
                  ),
                  const SizedBox(height: 8),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 250),
                    child: _buildPendingNightsSection(context),
                  ),
                  const SizedBox(height: 16),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 300),
                    child: _buildCreateNightButton(context, userProvider),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
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
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    return NeonBorder(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      strokeWidth: isDark ? 2.5 : 2,
      blurRadius: isDark ? 16 : 10,
      colors: const [
        Color(0xFFA855F7),
        Color(0xFFEC4899),
        Color(0xFF06B6D4),
        Color(0xFFA855F7),
      ],
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        blur: isDark ? 12 : 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.5 : 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: avatar.AfterlifeAvatar(
                    initials: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    status: avatar.AvatarStatus.online,
                    size: 66,
                    showStatusIndicator: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AfterlifeTextTheme.headlineMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.4 : 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'NIVEL $userLevel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.5 : 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.35 : 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.white, size: 13),
                      const SizedBox(width: 5),
                      const Text(
                        'PRÓXIMOS LOGROS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAchievementsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsRow() {
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    if (_isLoadingAchievements) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_upcomingAchievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Completa más acciones para desbloquear logros',
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _upcomingAchievements.map((achievement) {
        return GestureDetector(
          onTap: () {
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

  Widget _buildPendingNightsSection(BuildContext context) {
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);
    final textDisabled = AfterlifeColors.textDisabledAdaptive(context);

    if (_isLoadingNights) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorNights != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AfterlifeColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              'Error al cargar noches: $_errorNights',
              style: TextStyle(color: textPrimary),
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
          color: AfterlifeColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.nightlight_round,
              color: AfterlifeColors.electricLilac.withValues(alpha: 0.5),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay noches en espera',
              style: AfterlifeTextTheme.bodyLarge.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea una nueva noche o espera a que tus amigos te inviten',
              textAlign: TextAlign.center,
              style: AfterlifeTextTheme.bodySmall.copyWith(
                color: textDisabled,
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AfterlifeColors.neonOrange.withValues(alpha: isDark ? 0.4 : 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.nightlight_round, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'NOCHES EN ESPERA  ${_availableNights.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
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
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    final players = night['players'] as List? ?? [];
    final currentPlayers = players.length;
    final maxPlayers = night['maxPlayers'] ?? 0;
    final bool isFull = currentPlayers >= maxPlayers;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(16),
      tint: AfterlifeColors.neonOrange.withValues(alpha: 0.06),
      border: BorderSide(
        color: AfterlifeColors.neonOrange.withValues(alpha: isDark ? 0.2 : 0.15),
        width: 1,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                          child: const Icon(Icons.group, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                night['groupName'] ?? 'Grupo',
                                style: AfterlifeTextTheme.titleMedium.copyWith(fontWeight: FontWeight.w600, color: textPrimary),
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
                            color: AfterlifeColors.neonOrange.withValues(alpha: 0.2),
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
                          style: AfterlifeTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jugadores: $currentPlayers/$maxPlayers',
                          style: AfterlifeTextTheme.bodySmall.copyWith(color: textSecondary),
                        ),
                        if (!isFull)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AfterlifeColors.acidGreen.withValues(alpha: 0.2),
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
                          backgroundColor: isFull ? Colors.grey.withValues(alpha: 0.3) : AfterlifeColors.neonOrange,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNightButton(BuildContext context, UserProvider userProvider) {
    return NeonBorder(
      borderRadius: BorderRadius.circular(16),
      strokeWidth: 3,
      blurRadius: 20,
      colors: const [
        Color(0xFFA855F7),
        Color(0xFFEC4899),
        Color(0xFF06B6D4),
        Color(0xFFA855F7),
      ],
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              if (userProvider.activeNightId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ya tienes una noche activa. Finalízala antes de crear una nueva.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              _confettiController.play();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateNightScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'CREAR NUEVA NOCHE',
                    style: AfterlifeTextTheme.labelLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

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
          style: AfterlifeTextTheme.labelSmall.copyWith(color: textSecondary),
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
                border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3), width: 2),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(AfterlifeColors.electricLilac),
                strokeWidth: 3,
              ),
            ),
            Icon(icon, color: AfterlifeColors.electricLilac.withValues(alpha: 0.8), size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: AfterlifeTextTheme.labelSmall.copyWith(color: AfterlifeColors.textSecondaryAdaptive(context))),
        Text('${(progress * 100).toInt()}%', style: AfterlifeTextTheme.labelSmall.copyWith(color: AfterlifeColors.electricLilac, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniRankingCard() {
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    return FutureBuilder<List<UserRankData>>(
      future: _rankingFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
          return const SizedBox.shrink();
        }
        final top3 = snapshot.data!.take(3).toList();
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.leaderboard_rounded,
                      color: AfterlifeColors.electricPurple, size: 18),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                    ).createShader(b),
                    child: const Text(
                      'RANKING AMIGOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...top3.asMap().entries.map((entry) {
                final i = entry.key;
                final user = entry.value;
                final medals = ['🥇', '🥈', '🥉'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(medals[i], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          user.username,
                          style: TextStyle(
                            color: user.isCurrentUser
                                ? AfterlifeColors.electricPurple
                                : textPrimary.withValues(alpha: 0.85),
                            fontWeight: user.isCurrentUser
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${user.points} pts',
                        style: const TextStyle(
                          color: AfterlifeColors.neonPink,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMotivationalCard(int nightsCompleted) {
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    final messages = [
      ('🌙', '¡Crea una noche y empieza a ganar puntos!'),
      ('🏆', '¡Completa retos para subir en el ranking!'),
      ('👥', '¡Invita amigos para multiplicar la diversion!'),
      ('⚡', '¡Cada reto completado te acerca al siguiente nivel!'),
      ('🎯', '¡Desbloquea logros y sube en el ranking mundial!'),
    ];
    final msg = messages[nightsCompleted % messages.length];

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tint: AfterlifeColors.acidGreen.withValues(alpha: 0.08),
      border: BorderSide(
        color: AfterlifeColors.acidGreen.withValues(alpha: isDark ? 0.2 : 0.25),
        width: 1,
      ),
      child: Row(
        children: [
          Text(msg.$1, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg.$2,
              style: TextStyle(
                color: textPrimary.withValues(alpha: 0.75),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinigamesCard(BuildContext context) {
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MinigamesScreen()),
      ),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        tint: AfterlifeColors.cyanBlue.withValues(alpha: 0.08),
        border: BorderSide(
          color: AfterlifeColors.cyanBlue.withValues(alpha: isDark ? 0.25 : 0.3),
          width: 1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MINIJUEGOS',
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 3),
                  Text('Verdad, Yo Nunca, Retos...',
                      style: TextStyle(color: textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AfterlifeColors.cyanBlue.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }
}

// lib/screens/profile_screen.dart
import 'package:afterlife_projects/components/animations/animated_entry.dart';
import 'package:afterlife_projects/components/effects/glass_card.dart';
import 'package:afterlife_projects/edit_profile.dart';
import 'package:afterlife_projects/journal_screen.dart';
import 'package:afterlife_projects/AchievementsScreen.dart';
import 'package:afterlife_projects/screens/visited_clubs_screen.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:afterlife_projects/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AchievementService _achievementService = AchievementService();
  List<Map<String, dynamic>> _recentAchievements = [];
  bool _loadingAchievements = true;
  bool _achievementsLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadRecentAchievements();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_achievementsLoadedOnce) return;
    final userProvider = Provider.of<UserProvider>(context);
    if (!userProvider.isLoading) {
      _achievementsLoadedOnce = true;
      _loadRecentAchievements();
    }
  }

  Future<void> _loadRecentAchievements() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final unlockedRaw = userProvider.unlockedAchievements;
    if (unlockedRaw.isEmpty) {
      setState(() {
        _recentAchievements = [];
        _loadingAchievements = false;
      });
      return;
    }

    setState(() => _loadingAchievements = true);

    try {
      final allAchievements = await _achievementService.getAllAchievements();
      final Map<String, dynamic> achievementMap = {
        for (var a in allAchievements) a.id: {'title': a.title, 'icon': a.icon}
      };

      List<Map<String, dynamic>> temp = [];
      for (var item in unlockedRaw) {
        final id = item['achievementId'] as String;
        dynamic unlockedAtValue = item['unlockedAt'];
        DateTime? unlockedAt;
        if (unlockedAtValue is Timestamp) {
          unlockedAt = unlockedAtValue.toDate();
        } else if (unlockedAtValue is DateTime) {
          unlockedAt = unlockedAtValue;
        }
        if (achievementMap.containsKey(id)) {
          temp.add({
            'title': achievementMap[id]['title'],
            'icon': achievementMap[id]['icon'],
            'unlockedAt': unlockedAt ?? DateTime.now(),
          });
        }
      }
      temp.sort((a, b) => b['unlockedAt'].compareTo(a['unlockedAt']));
      final recent = temp.take(3).toList();

      setState(() {
        _recentAchievements = recent;
        _loadingAchievements = false;
      });
    } catch (e) {
      setState(() => _loadingAchievements = false);
      debugPrint('Error cargando logros recientes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(
                color: AfterlifeColors.electricPurple,
              ),
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
        final currentUser = FirebaseAuth.instance.currentUser;
        final email = currentUser?.email ?? 'sin email';
        final userName = userData?['username'] ?? email.split('@').first;
        final userHandle = '@${userName.toLowerCase().replaceAll(' ', '')}';
        final userLevel = userData?['level'] ?? 1;
        final totalPoints = userData?['points'] ?? 0;
        final nightsAttended = userData?['nightsCompleted'] ?? 0;
        final challengesCompleted = userData?['challengesCompleted'] ?? 0;
        final friendsCount = userData?['friendsCount'] ?? 0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildGradientHeader(userName, userHandle, userLevel, totalPoints),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    AnimatedEntry(
                      delay: const Duration(milliseconds: 100),
                      child: _buildStatsRow(nightsAttended, challengesCompleted, friendsCount, totalPoints),
                    ),
                    const SizedBox(height: 24),
                    AnimatedEntry(
                      delay: const Duration(milliseconds: 200),
                      child: _buildActionGrid(context),
                    ),
                    const SizedBox(height: 24),
                    AnimatedEntry(
                      delay: const Duration(milliseconds: 300),
                      child: _buildRecentAchievements(),
                    ),
                    const SizedBox(height: 24),
                    AnimatedEntry(
                      delay: const Duration(milliseconds: 400),
                      child: _buildLogoutButton(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientHeader(String userName, String userHandle, int userLevel, int totalPoints) {
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    return Container(
      decoration: BoxDecoration(
        gradient: AfterlifeColors.headerGradient(context),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.settings_outlined, color: textPrimary.withValues(alpha: 0.7), size: 24),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(Icons.edit_outlined, color: AfterlifeColors.electricPurple.withValues(alpha: 0.8), size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 88,
                    height: 88,
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
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A0533) : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
                    ).createShader(bounds),
                    child: Text(
                      userHandle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.4 : 0.25),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      'NIVEL $userLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int nights, int challenges, int friends, int points) {
    final isDark = AfterlifeColors.isDark(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      border: BorderSide(color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.2 : 0.15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(Icons.nightlight_round, nights, 'Noches', AfterlifeColors.neonPink),
          _buildStatDivider(),
          _buildStatColumn(Icons.flash_on, challenges, 'Retos', AfterlifeColors.cyanBlue),
          _buildStatDivider(),
          _buildStatColumn(Icons.group, friends, 'Amigos', AfterlifeColors.acidGreen),
          _buildStatDivider(),
          _buildStatColumn(Icons.star, points, 'Puntos', AfterlifeColors.neonOrange),
        ],
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, int value, String label, Color color) {
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AfterlifeColors.dividerAdaptive(context),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionCard(
        label: 'MIS LOGROS',
        icon: Icons.emoji_events,
        gradientColors: const [Color(0xFF7C3AED), Color(0xFFA855F7)],
        glowColor: AfterlifeColors.electricPurple,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
      ),
      _ActionCard(
        label: 'MI DIARIO',
        icon: Icons.menu_book,
        gradientColors: const [Color(0xFF0E7490), Color(0xFF06B6D4)],
        glowColor: AfterlifeColors.cyanBlue,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
      ),
      _ActionCard(
        label: 'EDITAR PERFIL',
        icon: Icons.edit,
        gradientColors: const [Color(0xFF065F46), Color(0xFF84CC16)],
        glowColor: AfterlifeColors.acidGreen,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
      ),
      _ActionCard(
        label: 'LOCALES',
        icon: Icons.location_on,
        gradientColors: const [Color(0xFFBE185D), Color(0xFFEC4899)],
        glowColor: AfterlifeColors.neonPink,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitedClubsScreen())),
      ),
      _ActionCard(
        label: 'AJUSTES',
        icon: Icons.settings,
        gradientColors: const [Color(0xFF92400E), Color(0xFFF59E0B)],
        glowColor: AfterlifeColors.neonOrange,
        onTap: () => Navigator.pushNamed(context, '/settings'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: actions.map((action) => _buildActionCard(action)).toList(),
    );
  }

  Widget _buildActionCard(_ActionCard action) {
    return GestureDetector(
      onTap: action.onTap,
      child: GlassCard(
        gradient: LinearGradient(
          colors: action.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        blur: 8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              action.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements() {
    final isDark = AfterlifeColors.isDark(context);
    final textSecondary = AfterlifeColors.textSecondaryAdaptive(context);
    final textDisabled = AfterlifeColors.textDisabledAdaptive(context);

    if (_loadingAchievements) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  colors: [AfterlifeColors.acidGreen, AfterlifeColors.cyanBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'LOGROS RECIENTES',
              style: TextStyle(
                color: AfterlifeColors.acidGreen,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_recentAchievements.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            tint: AfterlifeColors.acidGreen.withValues(alpha: 0.05),
            border: BorderSide(color: AfterlifeColors.acidGreen.withValues(alpha: isDark ? 0.15 : 0.2)),
            child: Column(
              children: [
                Icon(Icons.lock_outline, color: textDisabled, size: 32),
                const SizedBox(height: 10),
                Text(
                  'Aun no has desbloqueado logros',
                  style: TextStyle(color: textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Juega noches y completa retos para conseguirlos',
                  style: TextStyle(color: textDisabled, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: _recentAchievements.map((ach) {
              return SizedBox(
                width: 100,
                child: AchievementBadge(
                  title: ach['title'],
                  icon: ach['icon'],
                  isUnlocked: true,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authService = AuthService();
    return GestureDetector(
      onTap: () => _showLogoutDialog(context, authService),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 15),
        tint: AfterlifeColors.neonPink.withValues(alpha: 0.08),
        border: BorderSide(color: AfterlifeColors.neonPink.withValues(alpha: 0.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AfterlifeColors.neonPink, size: 20),
            const SizedBox(width: 10),
            Text(
              'CERRAR SESION',
              style: TextStyle(
                color: AfterlifeColors.neonPink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    final isDark = AfterlifeColors.isDark(context);
    final textPrimary = AfterlifeColors.textPrimaryAdaptive(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A0D2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AfterlifeColors.neonPink.withValues(alpha: 0.3)),
        ),
        title: Text('Cerrar sesion', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Seguro que quieres salir?', style: TextStyle(color: textPrimary.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: textPrimary.withValues(alpha: 0.5))),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AfterlifeColors.neonPink, Color(0xFFBE185D)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await authService.signOut();
                } catch (e) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error al cerrar sesion: $e'), backgroundColor: Theme.of(ctx).colorScheme.error),
                  );
                }
              },
              child: const Text('SALIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
  });
}

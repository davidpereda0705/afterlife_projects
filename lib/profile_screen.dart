// lib/screens/profile_screen.dart
import 'package:afterlife_projects/edit_profile.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  Text('Error al cargar perfil: ${userProvider.error}',
                      style: const TextStyle(color: Colors.white)),
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
        final achievementsCount = userData?['achievementsCount'] ?? 0;

        final recentAchievements = const [
          {'title': 'SOCIAL', 'icon': Icons.people, 'unlocked': true},
          {'title': 'NO VETERANO', 'icon': Icons.military_tech, 'unlocked': true},
          {'title': 'FIESTERO', 'icon': Icons.nightlife, 'unlocked': true},
        ];

        return Scaffold(
          backgroundColor: AfterlifeColors.background,
          appBar: AppBar(
            backgroundColor: AfterlifeColors.background,
            elevation: 0,
            title: Text(
              'Perfil',
              style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(userName, userHandle, userLevel, totalPoints),
              const SizedBox(height: 24),
              _buildStatsGrid(nightsAttended, challengesCompleted, friendsCount, achievementsCount),
              const SizedBox(height: 24),
              _buildRecentAchievements(recentAchievements),
              const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(String userName, String userHandle, int userLevel, int totalPoints) {
    return AfterlifeCard(
      child: Row(
        children: [
          AfterlifeAvatar(
            initials: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            status: AvatarStatus.online,
            size: 80,
            showStatusIndicator: true,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  userHandle,
                  style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.electricLilac.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
                      ),
                      child: Text('NIVEL $userLevel', style: AfterlifeTextTheme.labelSmall.copyWith(color: AfterlifeColors.electricLilac, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AfterlifeColors.neonOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: AfterlifeColors.neonOrange, size: 14),
                          const SizedBox(width: 4),
                          Text('$totalPoints pts', style: TextStyle(color: AfterlifeColors.neonOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int nights, int challenges, int friends, int achievements) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Noches', nights.toString(), Icons.nightlight_round, AfterlifeColors.neonPink),
        _buildStatCard('Retos', challenges.toString(), Icons.emoji_events, AfterlifeColors.cyanBlue),
        _buildStatCard('Amigos', friends.toString(), Icons.group, AfterlifeColors.acidGreen),
        _buildStatCard('Logros', achievements.toString(), Icons.military_tech, AfterlifeColors.electricPurple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return AfterlifeCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(List<Map<String, dynamic>> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'LOGROS RECIENTES',
            style: TextStyle(color: AfterlifeColors.acidGreen, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: achievements.map((ach) {
              return SizedBox(
                width: 100,
                child: AchievementBadge(
                  title: ach['title'],
                  icon: ach['icon'],
                  isUnlocked: ach['unlocked'],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final authService = AuthService();

    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          },
          icon: Icon(Icons.edit, color: AfterlifeColors.cyanBlue),
          label: Text('EDITAR PERFIL', style: TextStyle(color: AfterlifeColors.cyanBlue)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AfterlifeColors.cyanBlue.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context, authService),
          icon: Icon(Icons.logout, color: AfterlifeColors.neonPink),
          label: Text('CERRAR SESIÓN', style: TextStyle(color: AfterlifeColors.neonPink)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AfterlifeColors.neonPink.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AfterlifeColors.surfaceDark,
        title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres salir?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: AfterlifeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await authService.signOut();
                // El StreamBuilder en main.dart redirigirá a LoginPage
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AfterlifeColors.neonPink),
            child: const Text('SALIR'),
          ),
        ],
      ),
    );
  }
}
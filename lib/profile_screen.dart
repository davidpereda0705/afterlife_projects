// lib/screens/profile_screen.dart
import 'package:afterlife_projects/components/login_page.dart';
import 'package:afterlife_projects/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Datos de ejemplo (cámbialos por los reales cuando tengas backend)
  static const String userName = 'Carlos';
  static const String userHandle = '@carlos_after';
  static const int userLevel = 12;
  static const int totalPoints = 3450;
  static const int nightsAttended = 18;
  static const int challengesCompleted = 47;
  static const int friendsCount = 24;
  static const int achievementsCount = 8;

  static const List<Map<String, dynamic>> recentAchievements = [
    {'title': 'SOCIAL', 'icon': Icons.people, 'unlocked': true},
    {'title': 'NO VETERANO', 'icon': Icons.military_tech, 'unlocked': true},
    {'title': 'FIESTERO', 'icon': Icons.nightlife, 'unlocked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Perfil',
          style: AfterlifeTextTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AfterlifeColors.textPrimary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración - Próximamente')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildRecentAchievements(),
          const SizedBox(height: 24),
          _buildActionButtons(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return AfterlifeCard(
      child: Row(
        children: [
          AfterlifeAvatar(
            initials: 'CR',
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
                  style: AfterlifeTextTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userHandle,
                  style: TextStyle(
                    color: AfterlifeColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.electricLilac.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AfterlifeColors.electricLilac.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'NIVEL $userLevel',
                        style: AfterlifeTextTheme.labelSmall.copyWith(
                          color: AfterlifeColors.electricLilac,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.neonOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AfterlifeColors.neonOrange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalPoints pts',
                            style: TextStyle(
                              color: AfterlifeColors.neonOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Noches',
          nightsAttended.toString(),
          Icons.nightlight_round,
          AfterlifeColors.neonPink,
        ),
        _buildStatCard(
          'Retos',
          challengesCompleted.toString(),
          Icons.emoji_events,
          AfterlifeColors.cyanBlue,
        ),
        _buildStatCard(
          'Amigos',
          friendsCount.toString(),
          Icons.group,
          AfterlifeColors.acidGreen,
        ),
        _buildStatCard(
          'Logros',
          achievementsCount.toString(),
          Icons.military_tech,
          AfterlifeColors.electricPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AfterlifeCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AfterlifeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'LOGROS RECIENTES',
            style: TextStyle(
              color: AfterlifeColors.acidGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: recentAchievements.map((ach) {
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
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
          icon: Icon(Icons.edit, color: AfterlifeColors.cyanBlue),
          label: Text(
            'EDITAR PERFIL',
            style: TextStyle(color: AfterlifeColors.cyanBlue),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AfterlifeColors.cyanBlue.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            _showLogoutDialog(context);
          },
          icon: Icon(Icons.logout, color: AfterlifeColors.neonPink),
          label: Text(
            'CERRAR SESIÓN',
            style: TextStyle(color: AfterlifeColors.neonPink),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AfterlifeColors.neonPink.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AfterlifeColors.surfaceDark,
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que quieres salir?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AfterlifeColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Cierra el diálogo
              // Navegar a LoginPage reemplazando toda la pila
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AfterlifeColors.neonPink,
            ),
            child: const Text('SALIR'),
          ),
        ],
      ),
    );
  }
}

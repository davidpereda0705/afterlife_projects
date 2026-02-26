// lib/screens/achievements_screen.dart
import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/BottomNav.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _selectedIndex = 3; // 3 = Logros

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.group_outlined, selectedIcon: Icons.group, label: 'Amigos'),
    BottomNavItem(icon: Icons.nightlight_outlined, selectedIcon: Icons.nightlight_round, label: 'Noches'),
    BottomNavItem(icon: Icons.emoji_events_outlined, selectedIcon: Icons.emoji_events, label: 'Logros'),
    BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Perfil'),
  ];

  // Datos de ejemplo del usuario
  final String userName = 'Carlos';
  final int userLevel = 12;
  final int totalPoints = 2450;
  final int nightsAttended = 18;
  final int challengesCompleted = 47;

  // Logros del usuario
  final List<Map<String, dynamic>> _achievements = [
    // DESBLOQUEADOS
    {'title': 'SOCIAL', 'icon': Icons.people, 'unlocked': true, 'description': 'Únete a 5 noches', 'date': '15/03/2025'},
    {'title': 'NO VETERANO', 'icon': Icons.military_tech, 'unlocked': true, 'description': 'Completa tu primera noche', 'date': '10/03/2025'},
    {'title': 'FIESTERO', 'icon': Icons.nightlife, 'unlocked': true, 'description': 'Asiste a 10 noches', 'date': '20/03/2025'},
    {'title': 'INFLUENCER', 'icon': Icons.camera_alt, 'unlocked': true, 'description': 'Sube 5 fotos de retos', 'date': '18/03/2025'},
    
    // BLOQUEADOS
    {'title': 'LEYENDA', 'icon': Icons.stars, 'unlocked': false, 'description': 'Completa 50 retos', 'progress': 0.47},
    {'title': 'MAESTRO', 'icon': Icons.school, 'unlocked': false, 'description': 'Crea 10 noches', 'progress': 0.3},
    {'title': 'INQUEBRANTABLE', 'icon': Icons.verified, 'unlocked': false, 'description': 'Nivel 25', 'progress': 0.48},
    {'title': 'SOCIALITE', 'icon': Icons.diversity_3, 'unlocked': false, 'description': 'Ten 20 amigos', 'progress': 0.6},
    {'title': 'NOCTÁMBULO', 'icon': Icons.nights_stay, 'unlocked': false, 'description': '100 noches', 'progress': 0.18},
    {'title': 'LEYENDA VIVA', 'icon': Icons.auto_awesome, 'unlocked': false, 'description': 'Completa todos los logros', 'progress': 0.35},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Logros',
          style: AfterlifeTextTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AfterlifeAvatar(
              initials: 'CR',
              status: AvatarStatus.online,
              size: 40,
              showStatusIndicator: true,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen rápido
          _buildSummaryCard(),
          
          // Lista de logros (sin categorías)
          Expanded(
            child: _buildAchievementsList(),
          ),
        ],
      ),
      bottomNavigationBar: AfterlifeBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GroupPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NightSelectionScreen()),
              );
              break;
            case 3:
              // Ya estamos aquí
              break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pantalla de Perfil - Próximamente')),
              );
              break;
          }
        },
        items: _navItems,
      ),
    );
  }

  // Tarjeta de resumen
  Widget _buildSummaryCard() {
    int unlockedCount = _achievements.where((a) => a['unlocked']).length;
    int totalCount = _achievements.length;
    double progress = unlockedCount / totalCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AfterlifeColors.electricLilac.withOpacity(0.3),
            AfterlifeColors.electricPurple.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AfterlifeColors.electricLilac.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$userName',
                    style: AfterlifeTextTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIVEL $userLevel',
                    style: TextStyle(
                      color: AfterlifeColors.electricLilac,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AfterlifeColors.electricPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: AfterlifeColors.neonOrange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$totalPoints pts',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESO GENERAL',
                style: TextStyle(
                  color: AfterlifeColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$unlockedCount/$totalCount',
                style: TextStyle(
                  color: AfterlifeColors.electricLilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(AfterlifeColors.electricLilac),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Noches', nightsAttended.toString(), Icons.nightlight_round),
              _buildStatItem('Retos', challengesCompleted.toString(), Icons.emoji_events),
              _buildStatItem('Logros', unlockedCount.toString(), Icons.military_tech),
            ],
          ),
        ],
      ),
    );
  }

  // Item de estadística
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AfterlifeColors.neonPink, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AfterlifeColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AfterlifeColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Lista de logros (simplificada)
  Widget _buildAchievementsList() {
    // Separar desbloqueados y bloqueados
    final unlocked = _achievements.where((a) => a['unlocked']).toList();
    final locked = _achievements.where((a) => !a['unlocked']).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sección: RECIENTEMENTE DESBLOQUEADOS
        if (unlocked.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'RECIENTEMENTE DESBLOQUEADOS',
              style: TextStyle(
                color: AfterlifeColors.acidGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: unlocked.length,
              itemBuilder: (context, index) {
                final achievement = unlocked[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: AchievementBadge(
                    title: achievement['title'],
                    icon: achievement['icon'],
                    isUnlocked: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Sección: PRÓXIMOS LOGROS (con progreso)
        if (locked.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'PRÓXIMOS LOGROS',
              style: TextStyle(
                color: AfterlifeColors.neonOrange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          ...locked.map((achievement) => _buildLockedAchievement(achievement)).toList(),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  // Logro bloqueado con barra de progreso
  Widget _buildLockedAchievement(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AfterlifeColors.neonOrange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Icono del logro (versión pequeña)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AfterlifeColors.electricPurple.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AfterlifeColors.neonOrange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              achievement['icon'],
              color: AfterlifeColors.neonOrange.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Info y progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    color: AfterlifeColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    color: AfterlifeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: achievement['progress'],
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(AfterlifeColors.neonOrange),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(achievement['progress'] * 100).toInt()}%',
                      style: TextStyle(
                        color: AfterlifeColors.neonOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
}
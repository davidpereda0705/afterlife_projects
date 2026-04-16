import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  // Lista estática de logros (puede venir del provider más adelante)
  static const List<Map<String, dynamic>> _achievements = [
    {'title': 'SOCIAL', 'icon': Icons.people, 'unlocked': true, 'description': 'Únete a 5 noches', 'date': '15/03/2025'},
    {'title': 'NO VETERANO', 'icon': Icons.military_tech, 'unlocked': true, 'description': 'Completa tu primera noche', 'date': '10/03/2025'},
    {'title': 'FIESTERO', 'icon': Icons.nightlife, 'unlocked': true, 'description': 'Asiste a 10 noches', 'date': '20/03/2025'},
    {'title': 'INFLUENCER', 'icon': Icons.camera_alt, 'unlocked': true, 'description': 'Sube 5 fotos de retos', 'date': '18/03/2025'},
    {'title': 'LEYENDA', 'icon': Icons.stars, 'unlocked': false, 'description': 'Completa 50 retos', 'progress': 0.47},
    {'title': 'MAESTRO', 'icon': Icons.school, 'unlocked': false, 'description': 'Crea 10 noches', 'progress': 0.3},
    {'title': 'INQUEBRANTABLE', 'icon': Icons.verified, 'unlocked': false, 'description': 'Nivel 25', 'progress': 0.48},
    {'title': 'SOCIALITE', 'icon': Icons.diversity_3, 'unlocked': false, 'description': 'Ten 20 amigos', 'progress': 0.6},
    {'title': 'NOCTÁMBULO', 'icon': Icons.nights_stay, 'unlocked': false, 'description': '100 noches', 'progress': 0.18},
    {'title': 'LEYENDA VIVA', 'icon': Icons.auto_awesome, 'unlocked': false, 'description': 'Completa todos los logros', 'progress': 0.35},
  ];

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
        final userLevel = userData?['level'] ?? 1;
        final totalPoints = userData?['points'] ?? 0;
        final nightsAttended = userData?['nightsCompleted'] ?? 0;
        final challengesCompleted = userData?['challengesCompleted'] ?? 0;

        // Calcular logros desbloqueados (aún de lista estática)
        final unlockedCount = _achievements.where((a) => a['unlocked']).length;
        final totalCount = _achievements.length;

        return Scaffold(
          backgroundColor: AfterlifeColors.background,
          body: Column(
            children: [
              _buildSummaryCard(
                userName: userName,
                userLevel: userLevel,
                totalPoints: totalPoints,
                nightsAttended: nightsAttended,
                challengesCompleted: challengesCompleted,
                unlockedCount: unlockedCount,
                totalCount: totalCount,
              ),
              Expanded(
                child: _buildAchievementsList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String userName,
    required int userLevel,
    required int totalPoints,
    required int nightsAttended,
    required int challengesCompleted,
    required int unlockedCount,
    required int totalCount,
  }) {
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
                    userName,
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

  Widget _buildAchievementsList() {
    final unlocked = _achievements.where((a) => a['unlocked']).toList();
    final locked = _achievements.where((a) => !a['unlocked']).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
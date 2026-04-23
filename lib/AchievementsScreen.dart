// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../providers/user_provider.dart';
import '../theme/colors.dart';
import '../theme/text_theme.dart';
import '../components/AfterLifeCard.dart';
import '../components/AchievementBadge.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _allAchievements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final achievements = await _achievementService.getAllAchievements();
      setState(() {
        _allAchievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading || _isLoading) {
          return const Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (userProvider.error != null || _error != null) {
          return Scaffold(
            backgroundColor: AfterlifeColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error ?? _error ?? 'Error desconocido',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      userProvider.refresh();
                      _loadAchievements();
                    },
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
        final friendsCount = userData?['friendsCount'] ?? 0;
        final photosUploaded = userData?['photosUploaded'] ?? 0;
        final nightsCreated = userData?['nightsCreated'] ?? 0;

        final unlockedIds = userProvider.unlockedAchievements.map((e) => e['achievementId'] as String).toList();
        final unlockedCount = unlockedIds.length;
        final totalCount = _allAchievements.length;

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
                child: _buildAchievementsList(
                  unlockedIds,
                  nightsAttended,
                  challengesCompleted,
                  userLevel,
                  friendsCount,
                  photosUploaded,
                  nightsCreated,
                ),
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
    double progress = totalCount > 0 ? unlockedCount / totalCount : 0;

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
        border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
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
                    style: AfterlifeTextTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIVEL $userLevel',
                    style: TextStyle(color: AfterlifeColors.electricLilac, fontWeight: FontWeight.bold),
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
                    Text('$totalPoints pts', style: const TextStyle(color: Colors.white)),
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
                style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text('$unlockedCount/$totalCount', style: TextStyle(color: AfterlifeColors.electricLilac, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(AfterlifeColors.electricLilac),
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
        Text(value, style: TextStyle(color: AfterlifeColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildAchievementsList(
    List<String> unlockedIds,
    int nightsAttended,
    int challengesCompleted,
    int level,
    int friendsCount,
    int photosUploaded,
    int nightsCreated,
  ) {
    final unlocked = _allAchievements.where((a) => unlockedIds.contains(a.id)).toList();
    final locked = _allAchievements.where((a) => !unlockedIds.contains(a.id)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unlocked.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'RECIENTEMENTE DESBLOQUEADOS',
              style: TextStyle(color: AfterlifeColors.acidGreen, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
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
                    title: achievement.title,
                    icon: achievement.icon,
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
              style: TextStyle(color: AfterlifeColors.neonOrange, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ),
          ...locked.map((achievement) => _buildLockedAchievement(
                achievement,
                nightsAttended,
                challengesCompleted,
                level,
                friendsCount,
                photosUploaded,
                nightsCreated,
              )),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLockedAchievement(
    Achievement achievement,
    int nightsAttended,
    int challengesCompleted,
    int level,
    int friendsCount,
    int photosUploaded,
    int nightsCreated,
  ) {
    final progress = _achievementService.getProgress(
      achievement,
      nightsCompleted: nightsAttended,
      challengesCompleted: challengesCompleted,
      level: level,
      friendsCount: friendsCount,
      photosUploaded: photosUploaded,
      nightsCreated: nightsCreated,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AfterlifeColors.neonOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AfterlifeColors.electricPurple.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AfterlifeColors.neonOrange.withOpacity(0.3), width: 1),
            ),
            child: Icon(achievement.icon, color: AfterlifeColors.neonOrange.withOpacity(0.5), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title, style: TextStyle(color: AfterlifeColors.textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(achievement.description, style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(AfterlifeColors.neonOrange),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(progress * 100).toInt()}%', style: TextStyle(color: AfterlifeColors.neonOrange, fontSize: 12, fontWeight: FontWeight.bold)),
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
import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendProfileScreen extends StatelessWidget {
  final String uid;
  final String friendName;

  const FriendProfileScreen({
    super.key,
    required this.uid,
    required this.friendName,
  });

  Future<Map<String, dynamic>?> _getFriendData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getFriendData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AfterlifeColors.electricPurple)),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(child: Text('Usuario no encontrado', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
          );
        }

        final username = data['username'] ?? friendName;
        final level = data['level'] ?? 1;
        final points = data['points'] ?? 0;
        final nights = data['nightsCompleted'] ?? 0;
        final challengesCount = data['challengesCompleted'] ?? 0;
        final friendsCount = data['friendsCount'] ?? 0;
        final achievementsCount = data['achievementsCount'] ?? 0;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
       icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              _buildHeader(username, level, points),
              const SizedBox(height: 24),
              _buildStatsGrid(context, nights, challengesCount, friendsCount, achievementsCount),
              const SizedBox(height: 32),
              _buildChallengesSection(context, challengesCount),
              const SizedBox(height: 32),
              _buildAchievementsSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, int level, int pts) {
    return AfterlifeCard(
      child: Row(
        children: [
          AfterlifeAvatar(
            initials: name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                  name,
                  style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.electricPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('LVL $level', style: const TextStyle(color: AfterlifeColors.electricPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.neonOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$pts PTS', style: const TextStyle(color: AfterlifeColors.neonOrange, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildStatsGrid(BuildContext context, int nights, int challenges, int friends, int achievements) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(context, 'Noches', nights.toString(), Icons.nightlight_round, AfterlifeColors.neonPink),
        _buildStatCard(context, 'Retos', challenges.toString(), Icons.emoji_events, AfterlifeColors.cyanBlue),
        _buildStatCard(context, 'Amigos', friends.toString(), Icons.group, AfterlifeColors.acidGreen),
        _buildStatCard(context, 'Logros', achievements.toString(), Icons.military_tech, AfterlifeColors.electricPurple),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return AfterlifeCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
       Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection(BuildContext context, int count) {
    // Simulamos algunos retos logrados ya que no hay una colección específica aún
    final List<String> mockChallenges = [
      'Selfie con el grupo',
      'Bailar con un extraño',
      'Infiltrado en la barra',
      'Conquistador de pistas',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RETOS LOGRADOS',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        if (count == 0)
          Text('Este usuario aún no ha completado retos.', style: TextStyle(color: Theme.of(context).disabledColor))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count > 4 ? 4 : count,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AfterlifeColors.cyanBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AfterlifeColors.acidGreen, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      mockChallenges[index % mockChallenges.length],
           style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, color: AfterlifeColors.neonOrange, size: 14),
                    const SizedBox(width: 4),
                    const Text('+150', style: TextStyle(color: AfterlifeColors.neonOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOGROS DESTACADOS',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            AchievementBadge(title: 'SOCIAL', icon: Icons.people, isUnlocked: true),
            AchievementBadge(title: 'EXPERTO', icon: Icons.stars, isUnlocked: true),
            AchievementBadge(title: 'NIGHT OWL', icon: Icons.nightlife, isUnlocked: false),
          ],
        ),
      ],
    );
  }
}

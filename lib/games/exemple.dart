import 'package:afterlife_projects/components/AchievementBadge.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterProgressBar.dart';
import 'package:flutter/material.dart';

class Exemple extends StatelessWidget {
  const Exemple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AfterlifeCard(child:   Text('Ejemplo de AfterlifeCard')),
          AchievementBadge(title: "Hola", icon: Icons.access_alarm, isUnlocked: false),
          AfterlifeAvatar(
            imageUrl: 'https://example.com/avatar.jpg',
            initials: 'JD',
            size: 60,
            status: AvatarStatus.online,
            backgroundColor: Colors.blueGrey,
            borderColor: Colors.white,
            showStatusIndicator: true,
          ),
          AfterProgressBar(progress: 0.10),
        ],
      ),
    );
  }
}
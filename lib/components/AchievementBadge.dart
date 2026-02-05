import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isUnlocked; // El ESTADO: ¿Lo tiene o no?

  const AchievementBadge({
    super.key,
    required this.title,
    required this.icon,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos el color según el estado
    final Color badgeColor = isUnlocked 
        ? AfterlifeColors.electricPurple 
        : Colors.grey.withOpacity(0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AfterlifeColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: badgeColor,
              width: 2,
            ),
            boxShadow: isUnlocked ? [
              BoxShadow(
                color: badgeColor.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: Icon(
            icon,
            color: badgeColor,
            size: 40,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }
}
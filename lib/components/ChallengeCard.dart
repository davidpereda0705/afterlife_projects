import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String points;
  final Gradient gradient;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.points,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(
            '+$points XP',
            style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
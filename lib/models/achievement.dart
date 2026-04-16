// lib/models/achievement.dart
import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String iconName;
  final String description;
  final String category; // 'nights', 'challenges', 'level', 'friends', 'photos', 'custom'
  final int requirement;
  final int points;
  final bool active;

  Achievement({
    required this.id,
    required this.title,
    required this.iconName,
    required this.description,
    required this.category,
    required this.requirement,
    required this.points,
    required this.active,
  });

  IconData get icon {
    switch (iconName) {
      case 'Icons.people':
        return Icons.people;
      case 'Icons.military_tech':
        return Icons.military_tech;
      case 'Icons.nightlife':
        return Icons.nightlife;
      case 'Icons.camera_alt':
        return Icons.camera_alt;
      case 'Icons.stars':
        return Icons.stars;
      case 'Icons.school':
        return Icons.school;
      case 'Icons.verified':
        return Icons.verified;
      case 'Icons.diversity_3':
        return Icons.diversity_3;
      case 'Icons.nights_stay':
        return Icons.nights_stay;
      case 'Icons.auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.emoji_events;
    }
  }

  factory Achievement.fromMap(Map<String, dynamic> map, String id) {
    return Achievement(
      id: id,
      title: map['title'] ?? '',
      iconName: map['icon'] ?? 'Icons.emoji_events',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      requirement: map['requirement'] ?? 0,
      points: map['points'] ?? 0,
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': iconName,
      'description': description,
      'category': category,
      'requirement': requirement,
      'points': points,
      'active': active,
    };
  }
}
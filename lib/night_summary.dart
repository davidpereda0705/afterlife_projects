import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class NightSummary {
  final String id;
  final String name;
  final String day;
  final String time;
  final String groupName;
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> challenges;
  final List<String> nightPhotos; // Firebase Storage URLs
  final DateTime timestamp;

  NightSummary({
    required this.id,
    required this.name,
    required this.day,
    required this.time,
    required this.groupName,
    required this.players,
    required this.challenges,
    required this.nightPhotos,
    required this.timestamp,
  });

  // ----- MÉTODOS PARA SHARED_PREFERENCES (JSON) -----
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'day': day,
      'time': time,
      'groupName': groupName,
      'players': players,
      'challenges': challenges.map((c) {
        final copy = Map<String, dynamic>.from(c);
        if (copy['proofBytes'] != null) {
          copy['proofBytes'] = List<int>.from(copy['proofBytes']);
        }
        return copy;
      }).toList(),
      'nightPhotos': nightPhotos,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NightSummary.fromJson(Map<String, dynamic> json) {
    return NightSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Noche sin nombre',
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      groupName: json['groupName'] ?? '',
      players: List<Map<String, dynamic>>.from(json['players'] ?? []),
      challenges: (json['challenges'] as List? ?? []).map((c) {
        final challenge = Map<String, dynamic>.from(c);
        if (challenge['proofBytes'] != null) {
          challenge['proofBytes'] = Uint8List.fromList(challenge['proofBytes']);
        }
        return challenge;
      }).toList(),
      nightPhotos: List<String>.from(json['nightPhotos'] ?? []),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }

  // ----- MÉTODOS PARA FIRESTORE -----
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'name': name,
      'day': day,
      'time': time,
      'groupName': groupName,
      'players': players,
      'challenges': challenges.map((c) {
        final copy = Map<String, dynamic>.from(c);
        if (copy['proofBytes'] != null) {
          if (copy['proofBytes'] is Uint8List) {
            copy['proofBytes'] = (copy['proofBytes'] as Uint8List).toList();
          } else if (copy['proofBytes'] is List<int>) {
            copy['proofBytes'] = copy['proofBytes'] as List<int>;
          }
        }
        return copy;
      }).toList(),
      'nightPhotos': nightPhotos,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory NightSummary.fromFirestoreMap(Map<String, dynamic> map, String docId) {
    final players = (map['players'] as List?)?.map((p) => Map<String, dynamic>.from(p)).toList() ?? [];
    final challenges = (map['challenges'] as List?)?.map((c) {
      final challenge = Map<String, dynamic>.from(c);
      if (challenge['proofBytes'] != null && challenge['proofBytes'] is List) {
        challenge['proofBytes'] = Uint8List.fromList(List<int>.from(challenge['proofBytes']));
      }
      return challenge;
    }).toList() ?? [];

    // nightPhotos: handle both URL strings (new) and legacy byte lists (old)
    final rawPhotos = map['nightPhotos'] as List? ?? [];
    final nightPhotos = rawPhotos
        .where((p) => p is String && p.isNotEmpty)
        .cast<String>()
        .toList();

    return NightSummary(
      id: docId,
      name: map['name'] ?? '',
      day: map['day'] ?? '',
      time: map['time'] ?? '',
      groupName: map['groupName'] ?? '',
      players: players,
      challenges: challenges,
      nightPhotos: nightPhotos,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

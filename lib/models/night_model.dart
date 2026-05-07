// lib/models/night_model.dart
import 'package:afterlife_projects/core/enums.dart';

class NightModel {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final String hostInitials;
  final String groupName;
  final String day;
  final String time;
  final int maxPlayers;
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> challenges;
  final List<String> nightPhotos; // o List<Uint8List> según tu caso
  final DateTime createdAt;
  final NightStatus status;

  NightModel({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.hostInitials,
    required this.groupName,
    required this.day,
    required this.time,
    required this.maxPlayers,
    required this.players,
    required this.challenges,
    required this.nightPhotos,
    required this.createdAt,
    this.status = NightStatus.waiting,
  });

  // 🔧 Método fromMap para crear desde Firestore
  factory NightModel.fromMap(Map<String, dynamic> map, String id) {
    return NightModel(
      id: id,
      name: map['name'] ?? '',
      hostId: map['hostId'] ?? '',
      hostName: map['hostName'] ?? '',
      hostInitials: map['hostInitials'] ?? '',
      groupName: map['groupName'] ?? '',
      day: map['day'] ?? '',
      time: map['time'] ?? '',
      maxPlayers: map['maxPlayers'] ?? 8,
      players: List<Map<String, dynamic>>.from(map['players'] ?? []),
      challenges: List<Map<String, dynamic>>.from(map['challenges'] ?? []),
      nightPhotos: List<String>.from(map['nightPhotos'] ?? []), // si son URLs
      createdAt: _parseDateTime(map['createdAt']),
      status: NightStatus.fromString(map['status'] as String?),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      return value.toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  // Opcional: toMap para guardar
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'hostInitials': hostInitials,
      'groupName': groupName,
      'day': day,
      'time': time,
      'maxPlayers': maxPlayers,
      'players': players,
      'challenges': challenges,
      'nightPhotos': nightPhotos,
      'createdAt': createdAt,
      'status': status.value,
    };
  }
}
import 'dart:typed_data';

class NightSummary {
  final String id;
  final String name;
  final String day;
  final String time;
  final String groupName;
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> challenges;
  final List<Uint8List> nightPhotos;
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
      'nightPhotos': nightPhotos.map((b) => List<int>.from(b)).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NightSummary.fromJson(Map<String, dynamic> json) {
    return NightSummary(
      id: json['id'],
      name: json['name'],
      day: json['day'],
      time: json['time'],
      groupName: json['groupName'],
      players: List<Map<String, dynamic>>.from(json['players']),
      challenges: (json['challenges'] as List).map((c) {
        final challenge = Map<String, dynamic>.from(c);
        if (challenge['proofBytes'] != null) {
          challenge['proofBytes'] = Uint8List.fromList(challenge['proofBytes']);
        }
        return challenge;
      }).toList(),
      nightPhotos: (json['nightPhotos'] as List).map((b) => Uint8List.fromList(b)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
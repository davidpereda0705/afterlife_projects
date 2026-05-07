import 'package:cloud_firestore/cloud_firestore.dart';

class UserRankData {
  final String id;
  final String username;
  final String handle;
  final int points;
  final int nightsCompleted;
  final int nightsCreated;
  final int level;
  final String? avatarUrl;
  final bool isCurrentUser;

  const UserRankData({
    required this.id,
    required this.username,
    this.handle = '',
    required this.points,
    required this.nightsCompleted,
    required this.nightsCreated,
    required this.level,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  int getValueFor(String sortBy) {
    switch (sortBy) {
      case 'nightsCompleted': return nightsCompleted;
      case 'nightsCreated': return nightsCreated;
      default: return points;
    }
  }
}

class RankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserRankData _docToRankData(QueryDocumentSnapshot doc, {bool isCurrentUser = false}) {
    final data = doc.data() as Map<String, dynamic>;
    return UserRankData(
      id: doc.id,
      username: data['username'] ?? 'Usuario',
      handle: data['handle'] ?? '',
      points: (data['points'] ?? 0) as int,
      nightsCompleted: (data['nightsCompleted'] ?? 0) as int,
      nightsCreated: (data['nightsCreated'] ?? 0) as int,
      level: (data['level'] ?? 1) as int,
      avatarUrl: data['avatarUrl'] as String?,
      isCurrentUser: isCurrentUser,
    );
  }

  Future<List<UserRankData>> getWorldRanking({
    String sortBy = 'points',
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('users')
        .orderBy(sortBy, descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => _docToRankData(d)).toList();
  }

  Future<List<UserRankData>> getFriendsRanking({
    required String userId,
    String sortBy = 'points',
  }) async {
    final friendsSnap = await _db
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    final friendIds = friendsSnap.docs.map((d) => d.id).toList();

    final List<UserRankData> result = [];

    // Fetch current user
    final currentUserDoc = await _db.collection('users').doc(userId).get();
    if (currentUserDoc.exists) {
      final data = currentUserDoc.data()!;
      result.add(UserRankData(
        id: userId,
        username: data['username'] ?? 'Tú',
        handle: data['handle'] ?? '',
        points: (data['points'] ?? 0) as int,
        nightsCompleted: (data['nightsCompleted'] ?? 0) as int,
        nightsCreated: (data['nightsCreated'] ?? 0) as int,
        level: (data['level'] ?? 1) as int,
        avatarUrl: data['avatarUrl'] as String?,
        isCurrentUser: true,
      ));
    }

    // Fetch friends in batches of 10
    for (int i = 0; i < friendIds.length; i += 10) {
      final batch = friendIds.skip(i).take(10).toList();
      if (batch.isEmpty) continue;
      final snap = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      for (final doc in snap.docs) {
        result.add(_docToRankData(doc));
      }
    }

    result.sort((a, b) => b.getValueFor(sortBy).compareTo(a.getValueFor(sortBy)));
    return result;
  }
}

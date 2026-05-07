import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisitedClubsScreen extends StatelessWidget {
  const VisitedClubsScreen({super.key});

  Stream<List<Map<String, dynamic>>> _visitedClubsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return [];
      final list = data['visitedClubs'] as List? ?? [];
      return List<Map<String, dynamic>>.from(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locales visitados'),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _visitedClubsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final clubs = snapshot.data!;
          if (clubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 60, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 16),
                  Text('Aún no has visitado ningún local', style: TextStyle(color: Theme.of(context).disabledColor)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,
            itemBuilder: (_, i) {
              final club = clubs[i];
              final timestamp = club['visitedAt'];
              DateTime? date;
              if (timestamp is Timestamp) date = timestamp.toDate();
              final dateStr = date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
              return AfterlifeCard(
                child: ListTile(
                  leading: const Icon(Icons.nightlife, color: AfterlifeColors.neonPink),
                  title: Text(club['name'] ?? 'Local desconocido'),
                  subtitle: Text('${club['city'] ?? ''} · $dateStr'),
                  trailing: Chip(
                    label: Text('${club['visitCount'] ?? 1}x', style: const TextStyle(fontSize: 12)),
                    backgroundColor: AfterlifeColors.electricPurple.withValues(alpha: 0.15),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// lib/services/journal_service.dart
import 'package:afterlife_projects/night_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _entriesCollection {
    if (_userId == null) throw Exception('Usuario no autenticado');
    return _firestore.collection('users').doc(_userId!).collection('journal_entries');
  }

  // Guardar una entrada del diario
  Future<void> saveEntry(NightSummary entry) async {
    final data = entry.toFirestoreMap();
    await _entriesCollection.doc(entry.id).set(data);
  }

  // Obtener todas las entradas del usuario ordenadas por fecha descendente
  Stream<List<NightSummary>> getEntriesStream() {
    return _entriesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NightSummary.fromFirestoreMap(data, doc.id);
      }).toList();
    });
  }

  // Eliminar una entrada por ID
  Future<void> deleteEntry(String entryId) async {
    await _entriesCollection.doc(entryId).delete();
  }
}
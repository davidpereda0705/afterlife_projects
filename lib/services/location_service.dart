import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  /// Solicita permisos y devuelve la posición actual
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  /// Sube la ubicación del usuario a Firestore para una noche específica
  Future<void> shareLocation(String nightId) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('No autenticado');

    final position = await getCurrentPosition();
    if (position == null) throw Exception('No se pudo obtener la ubicación');

    await _firestore
        .collection('night_locations')
        .doc(nightId)
        .collection('users')
        .doc(uid)
        .set({
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'accuracy': position.accuracy,
    });
  }

  /// Stream de ubicaciones de todos los usuarios en una noche
  Stream<List<Map<String, dynamic>>> getNightLocations(String nightId) {
    return _firestore
        .collection('night_locations')
        .doc(nightId)
        .collection('users')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return {
                'userId': doc.id,
                'lat': data['lat'],
                'lng': data['lng'],
                'timestamp': data['timestamp'],
              };
            }).toList());
  }

  /// Detener compartir ubicación
  Future<void> stopSharingLocation(String nightId) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _firestore
        .collection('night_locations')
        .doc(nightId)
        .collection('users')
        .doc(uid)
        .delete();
  }
}

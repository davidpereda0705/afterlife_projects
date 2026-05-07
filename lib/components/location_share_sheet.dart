import 'dart:async';

import 'package:afterlife_projects/services/location_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocationShareSheet extends StatefulWidget {
  final String nightId;
  final List<Map<String, dynamic>> players;

  const LocationShareSheet({super.key, required this.nightId, required this.players});

  @override
  State<LocationShareSheet> createState() => _LocationShareSheetState();
}

class _LocationShareSheetState extends State<LocationShareSheet> {
  final LocationService _locationService = LocationService();
  Timer? _shareTimer;
  bool _isSharing = false;
  List<Map<String, dynamic>> _locations = [];

  @override
  void initState() {
    super.initState();
    _locationService.getNightLocations(widget.nightId).listen((locs) {
      if (mounted) setState(() => _locations = locs);
    });
  }

  @override
  void dispose() {
    _shareTimer?.cancel();
    super.dispose();
  }

  void _startSharing() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSharing = true);
    await _locationService.shareLocation(widget.nightId);
    _shareTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        await _locationService.shareLocation(widget.nightId);
      } catch (_) {}
    });
  }

  void _stopSharing() async {
    HapticFeedback.mediumImpact();
    _shareTimer?.cancel();
    await _locationService.stopSharingLocation(widget.nightId);
    setState(() => _isSharing = false);
  }

  String _playerName(String userId) {
    final p = widget.players.firstWhere(
      (x) => (x['userId'] ?? x['uid'] ?? '') == userId,
      orElse: () => {'username': 'Desconocido'},
    );
    return p['username'] ?? p['name'] ?? 'Desconocido';
  }

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'desconocido';
    try {
      final date = (timestamp as Timestamp).toDate();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'ahora';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      return '${diff.inHours}h';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Ubicación del grupo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _isSharing ? 'Compartiendo tu ubicación cada 30s' : 'Activa para que te encuentren',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSharing ? _stopSharing : _startSharing,
                icon: Icon(_isSharing ? Icons.location_off : Icons.location_on),
                label: Text(_isSharing ? 'DETENER' : 'COMPARTIR MI UBICACIÓN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSharing ? AfterlifeColors.neonOrange : AfterlifeColors.acidGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_locations.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _locations.length,
                  itemBuilder: (_, i) {
                    final loc = _locations[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_pin_circle, color: AfterlifeColors.electricLilac),
                      title: Text(_playerName(loc['userId'])),
                      subtitle: Text('Lat: ${(loc['lat'] as double?)?.toStringAsFixed(4)} · Lng: ${(loc['lng'] as double?)?.toStringAsFixed(4)}'),
                      trailing: Text(_timeAgo(loc['timestamp']), style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

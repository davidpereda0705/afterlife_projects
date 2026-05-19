import 'package:afterlife_projects/night_summary.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../theme/colors.dart';
import '../theme/text_theme.dart';
import '../components/AfterLifeCard.dart';
import '../components/AfterButton.dart';


class NightSummaryDetailScreen extends StatelessWidget {
  final NightSummary entry;

  const NightSummaryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final players = List<Map<String, dynamic>>.from(entry.players)
      ..sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));
    final mvp = players.first;

    // Challenge proof images (stored as bytes in Firestore)
    final proofPhotos = entry.challenges
        .where((c) => c['proofBytes'] != null)
        .map((c) => c['proofBytes'] as Uint8List)
        .toList();

    // Night photos (stored as Uint8List bytes in Firestore)
    final nightPhotoBytes = entry.nightPhotos;

    final hasAnyPhotos = proofPhotos.isNotEmpty || nightPhotoBytes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          entry.name,
          style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general
            AfterlifeCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${entry.day} · ${entry.time} · ${entry.groupName}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('MVP', style: TextStyle(color: AfterlifeColors.neonOrange)),
                        Text(mvp['name'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        Text('${mvp['points']} pts', style: TextStyle(color: AfterlifeColors.neonOrange)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Clasificación completa
            AfterlifeCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CLASIFICACIÓN', style: TextStyle(color: AfterlifeColors.neonPink)),
                    const SizedBox(height: 12),
                    ...players.map((player) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${players.indexOf(player) + 1}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(player['name'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          Text('${player['points']} pts', style: const TextStyle(color: AfterlifeColors.neonOrange)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Galería de fotos
            if (hasAnyPhotos)
              AfterlifeCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📸 FOTOS', style: TextStyle(color: AfterlifeColors.cyanBlue)),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                        children: [
                          // Fotos de la noche (bytes guardados en Firestore)
                          ...nightPhotoBytes.map((bytes) => GestureDetector(
                            onTap: () => _showFullscreenBytes(context, bytes),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          )),
                          // Fotos de retos (bytes)
                          ...proofPhotos.map((bytes) => GestureDetector(
                            onTap: () => _showFullscreenBytes(context, bytes),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surface),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
            AfterButton(
              label: 'CERRAR',
              color: AfterlifeColors.electricLilac,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenBytes(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.memory(imageBytes, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

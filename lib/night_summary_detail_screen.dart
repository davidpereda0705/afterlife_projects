import 'package:afterlife_projects/night_summary.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../theme/colors.dart';
import '../theme/text_theme.dart';
import '../components/AfterLife_Avatar.dart';
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
    final allPhotos = [
      ...entry.challenges.where((c) => c['proofBytes'] != null).map((c) => c['proofBytes']),
      ...entry.nightPhotos,
    ];

    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AfterlifeColors.textPrimary),
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
                      style: TextStyle(color: AfterlifeColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('MVP', style: TextStyle(color: Color(0xFFF59E0B))),
                        Text(mvp['name'], style: TextStyle(color: Colors.white)),
                        Text('${mvp['points']} pts', style: TextStyle(color: Color(0xFFF59E0B))),
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
                    const Text('CLASIFICACIÓN', style: TextStyle(color: Color(0xFFEC4899))),
                    const SizedBox(height: 12),
                    ...players.map((player) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${players.indexOf(player) + 1}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(player['name'], style: const TextStyle(color: Colors.white))),
                          Text('${player['points']} pts', style: const TextStyle(color: Color(0xFFF59E0B))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Galería de fotos
            if (allPhotos.isNotEmpty)
              AfterlifeCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📸 FOTOS', style: TextStyle(color: Color(0xFF06B6D4))),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: allPhotos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullscreenImage(context, allPhotos[index]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                allPhotos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                              ),
                            ),
                          );
                        },
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

  void _showFullscreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
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
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
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
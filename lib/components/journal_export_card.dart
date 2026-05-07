import 'dart:typed_data';
import 'dart:ui';

import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class JournalExportCard extends StatefulWidget {
  final Map<String, dynamic> nightData;
  const JournalExportCard({super.key, required this.nightData});

  @override
  State<JournalExportCard> createState() => _JournalExportCardState();
}

class _JournalExportCardState extends State<JournalExportCard> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareAsImage() async {
    try {
      final Uint8List? image = await _screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );
      if (image == null) return;
      await Share.shareXFiles(
        [XFile.fromData(image, mimeType: 'image/png', name: 'afterlife_noche.png')],
        text: 'Mi noche en Afterlife 🍾',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.nightData['name'] ?? 'Noche';
    final day = widget.nightData['day'] ?? '';
    final players = (widget.nightData['players'] as List?)?.length ?? 0;
    final completed = (widget.nightData['challenges'] as List?)?.where((c) => c['completed'] == true).length ?? 0;
    final total = (widget.nightData['challenges'] as List?)?.length ?? 0;
    final totalPoints = ((widget.nightData['players'] as List?) ?? []).fold<int>(0, (sum, p) => sum + ((p['points'] ?? 0) as int));

    return Column(
      children: [
        Screenshot(
          controller: _screenshotController,
          child: Container(
            color: const Color(0xFF0D0D1A),
            padding: const EdgeInsets.all(24),
            child: AfterlifeCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('AFTERLIFE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4, color: AfterlifeColors.electricLilac)),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(day, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statColumn('$players', 'ASISTENTES'),
                        _statColumn('$completed/$total', 'RETOS'),
                        _statColumn('$totalPoints', 'PTS'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('¡Noche completada! 🎉', style: TextStyle(fontSize: 12, color: AfterlifeColors.acidGreen)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareAsImage,
            icon: const Icon(Icons.share),
            label: const Text('COMPARTIR RESUMEN'),
            style: ElevatedButton.styleFrom(backgroundColor: AfterlifeColors.acidGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ],
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 1)),
      ],
    );
  }
}

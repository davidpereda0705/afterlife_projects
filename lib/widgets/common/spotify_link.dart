import 'package:afterlife_projects/widgets/cards/afterlife_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyLinkSheet extends StatefulWidget {
  final String? currentUrl;
  final ValueChanged<String?> onUrlChanged;

  const SpotifyLinkSheet({super.key, this.currentUrl, required this.onUrlChanged});

  @override
  State<SpotifyLinkSheet> createState() => _SpotifyLinkSheetState();
}

class _SpotifyLinkSheetState extends State<SpotifyLinkSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUrl ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSpotify() async {
    HapticFeedback.lightImpact();
    final url = _controller.text.trim();
    if (url.isEmpty) {
      // Abrir búsqueda genérica en Spotify
      final uri = Uri.parse('https://open.spotify.com/search/afterlife%20playlist');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            Text('Playlist de la noche', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pega un enlace de Spotify o abre la app', style: TextStyle(color: Theme.of(context).disabledColor)),
            const SizedBox(height: 16),
            AfterlifeCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enlace de Spotify',
                        hintText: 'https://open.spotify.com/playlist/...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onUrlChanged(_controller.text.trim().isEmpty ? null : _controller.text.trim());
                          _openSpotify();
                        },
                        icon: const Icon(Icons.music_note),
                        label: const Text('ABRIR EN SPOTIFY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

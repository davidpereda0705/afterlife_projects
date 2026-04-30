
import 'package:afterlife_projects/night_summary.dart';
import 'package:afterlife_projects/services/journal_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:flutter/material.dart';
import 'night_summary_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();

  @override
  Widget build(BuildContext context) {
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
          'Mi Diario',
          style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<NightSummary>>(
        stream: _journalService.getEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: AfterlifeColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no hay noches registradas',
                    style: TextStyle(color: AfterlifeColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildJournalCard(entry);
            },
          );
        },
      ),
    );
  }

  Widget _buildJournalCard(NightSummary entry) {
    // --- Manejar el caso de que no haya jugadores ---
    if (entry.players.isEmpty) {
      return AfterlifeCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                style: AfterlifeTextTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sin datos de jugadores',
                style: TextStyle(color: AfterlifeColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final mvp = entry.players.reduce(
      (a, b) => ((a['points'] ?? 0) as num) > ((b['points'] ?? 0) as num) ? a : b,
    );
    final completedCount = entry.challenges.where((c) => c['completed'] == true).length;
    final photoCount = entry.challenges.where((c) => c['proofBytes'] != null).length + entry.nightPhotos.length;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await _journalService.deleteEntry(entry.id);
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NightSummaryDetailScreen(entry: entry)),
        ),
        child: AfterlifeCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        style: AfterlifeTextTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.day} · ${entry.time}',
                      style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AfterlifeColors.acidGreen, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'MVP: ${mvp['name']} (${mvp['points']} pts)',
                      style: TextStyle(color: AfterlifeColors.acidGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniStat(Icons.check_circle, '$completedCount retos', AfterlifeColors.cyanBlue),
                    const SizedBox(width: 16),
                    _buildMiniStat(Icons.photo, '$photoCount fotos', AfterlifeColors.neonPink),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
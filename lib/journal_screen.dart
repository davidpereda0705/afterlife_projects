import 'package:afterlife_projects/journal_storage.dart';
import 'package:afterlife_projects/night_summary.dart';
import 'package:afterlife_projects/night_summary_detail_screen.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_theme.dart';


class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<NightSummary> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final storage = JournalStorage();
    final entries = await storage.loadEntries();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Diario de noches',
          style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 80, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no hay noches registradas',
                        style: TextStyle(color: AfterlifeColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return _buildJournalCard(entry);
                  },
                ),
    );
  }

  Widget _buildJournalCard(NightSummary entry) {
    final mvp = entry.players.reduce((a, b) => (a['points'] ?? 0) > (b['points'] ?? 0) ? a : b);
    final allPhotos = [
      ...entry.challenges.where((c) => c['proofBytes'] != null).map((c) => c['proofBytes']),
      ...entry.nightPhotos,
    ].take(3).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NightSummaryDetailScreen(entry: entry),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AfterlifeColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.name,
                    style: AfterlifeTextTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${entry.day} · ${entry.time}',
                  style: TextStyle(color: AfterlifeColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.emoji_events, size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  'MVP: ${mvp['name']} (${mvp['points']} pts)',
                  style: TextStyle(color: AfterlifeColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (allPhotos.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allPhotos.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: MemoryImage(allPhotos[idx]),
                          fit: BoxFit.cover,
                        ),
                      ),
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
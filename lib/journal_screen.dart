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
    // Eliminamos Scaffold y AppBar
    return Container(
      color: AfterlifeColors.background,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 80, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Aún no hay noches registradas',
                        style: TextStyle(color: Colors.white54),
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
    // ... tu código igual, sin cambios
    return Container(); // placeholder
  }
}
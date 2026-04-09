import 'dart:convert';
import 'package:afterlife_projects/night_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalStorage {
  static const String _key = 'journal_entries';

  Future<void> saveEntry(NightSummary entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, existing);
  }

  Future<List<NightSummary>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entries = prefs.getStringList(_key);
    if (entries == null) return [];
    return entries
        .map((e) => NightSummary.fromJson(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
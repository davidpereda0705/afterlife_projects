import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ────────────────────────────────────────────────────────────────────────────
// Model
// ────────────────────────────────────────────────────────────────────────────

class OsmClub {
  final int id;
  final String name;
  final String? city;
  final String? street;
  final String? houseNumber;
  final String? website;
  final String? openingHours;
  final List<String> musicGenres;
  final double lat;
  final double lon;
  final String? phone;
  final String? instagram;
  final String? description;

  const OsmClub({
    required this.id,
    required this.name,
    this.city,
    this.street,
    this.houseNumber,
    this.website,
    this.openingHours,
    this.musicGenres = const [],
    required this.lat,
    required this.lon,
    this.phone,
    this.instagram,
    this.description,
  });

  String get address {
    final parts = [
      if (street != null) street!,
      if (houseNumber != null) houseNumber!,
      if (city != null) city!,
    ];
    return parts.isEmpty ? 'España' : parts.join(', ');
  }

  // ── Serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lon': lon,
        if (city != null) 'city': city,
        if (street != null) 'street': street,
        if (houseNumber != null) 'houseNumber': houseNumber,
        if (website != null) 'website': website,
        if (openingHours != null) 'openingHours': openingHours,
        if (musicGenres.isNotEmpty) 'musicGenres': musicGenres,
        if (phone != null) 'phone': phone,
        if (instagram != null) 'instagram': instagram,
        if (description != null) 'description': description,
      };

  factory OsmClub.fromJson(Map<String, dynamic> j) => OsmClub(
        id: j['id'] as int,
        name: j['name'] as String,
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
        city: j['city'] as String?,
        street: j['street'] as String?,
        houseNumber: j['houseNumber'] as String?,
        website: j['website'] as String?,
        openingHours: j['openingHours'] as String?,
        musicGenres: j['musicGenres'] != null
            ? List<String>.from(j['musicGenres'] as List)
            : const [],
        phone: j['phone'] as String?,
        instagram: j['instagram'] as String?,
        description: j['description'] as String?,
      );

  // ── OSM element parser ─────────────────────────────────────────────────

  factory OsmClub.fromElement(Map<String, dynamic> el) {
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};

    double? lat;
    double? lon;
    if (el['type'] == 'node') {
      lat = (el['lat'] as num?)?.toDouble();
      lon = (el['lon'] as num?)?.toDouble();
    } else if (el['center'] != null) {
      lat = (el['center']['lat'] as num?)?.toDouble();
      lon = (el['center']['lon'] as num?)?.toDouble();
    }

    if (lat == null || lon == null) throw Exception('no coords');

    final rawGenres = <String>{};
    for (final key in ['music', 'genre', 'music:genre']) {
      final v = tags[key] as String?;
      if (v != null) {
        rawGenres.addAll(v.split(';').map((s) => _normalizeGenre(s.trim())));
      }
    }

    return OsmClub(
      id: el['id'] as int,
      name: (tags['name'] as String?) ?? 'Sin nombre',
      city: tags['addr:city'] as String? ??
          tags['addr:municipality'] as String? ??
          tags['addr:town'] as String?,
      street: tags['addr:street'] as String?,
      houseNumber: tags['addr:housenumber'] as String?,
      website:
          tags['website'] as String? ?? tags['contact:website'] as String?,
      openingHours: tags['opening_hours'] as String?,
      musicGenres: rawGenres.toList(),
      lat: lat,
      lon: lon,
      phone: tags['phone'] as String? ?? tags['contact:phone'] as String?,
      instagram: tags['contact:instagram'] as String?,
      description:
          tags['description'] as String? ?? tags['note'] as String?,
    );
  }

  static String _normalizeGenre(String raw) {
    const map = {
      'techno': 'Techno',
      'house': 'House',
      'electronic': 'Electrónica',
      'electronics': 'Electrónica',
      'pop': 'Pop',
      'reggaeton': 'Reggaeton',
      'latin': 'Latino',
      'edm': 'EDM',
      'rnb': 'R&B',
      'hip_hop': 'Hip-Hop',
      'hiphop': 'Hip-Hop',
      'disco': 'Disco',
      'rock': 'Rock',
      'indie': 'Indie',
    };
    return map[raw.toLowerCase()] ?? _capitalize(raw);
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ────────────────────────────────────────────────────────────────────────────
// Service with two-level cache (memory + disk)
// ────────────────────────────────────────────────────────────────────────────

class OverpassService {
  static const _endpoint = 'https://overpass-api.de/api/interpreter';
  static const _diskKey = 'overpass_spain_clubs_v2';
  static const _diskTsKey = 'overpass_spain_clubs_ts_v2';
  static const _cacheDuration = Duration(hours: 6);

  // In-memory cache — survives tab switches, cleared on app restart
  static List<OsmClub>? _memCache;
  static DateTime? _memCacheTs;

  static final Map<String, List<OsmClub>> _provinceCache = {};
  static final Map<String, DateTime> _provinceCacheTs = {};

  static void invalidateCache() {
    _memCache = null;
    _memCacheTs = null;
    _provinceCache.clear();
    _provinceCacheTs.clear();
  }

  /// Loads all nightclubs in Spain.
  /// Returns cached data immediately if fresh; otherwise fetches from Overpass.
  Future<List<OsmClub>> loadAllSpainClubs({bool forceRefresh = false}) async {
    if (forceRefresh) invalidateCache();

    // 1 — memory cache
    if (_memCache != null && _memCacheTs != null) {
      if (DateTime.now().difference(_memCacheTs!) < _cacheDuration) {
        return _memCache!;
      }
    }

    // 2 — disk cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_diskKey);
      final ts = prefs.getInt(_diskTsKey);
      if (raw != null && ts != null) {
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        if (age < _cacheDuration.inMilliseconds) {
          final list = (jsonDecode(raw) as List)
              .map((e) => OsmClub.fromJson(e as Map<String, dynamic>))
              .toList();
          _memCache = list;
          _memCacheTs = DateTime.fromMillisecondsSinceEpoch(ts);
          return list;
        }
      }
    } catch (_) {
      // disk read failure → fall through to network
    }

    // 3 — network
    const query = '''
[out:json][timeout:90];
area["ISO3166-1"="ES"]["admin_level"="2"]->.es;
(
  node["amenity"="nightclub"](area.es);
  way["amenity"="nightclub"](area.es);
  relation["amenity"="nightclub"](area.es);
);
out center;
''';
    final result =
        await _runQuery(query, timeout: const Duration(seconds: 100));

    // Persist to both levels
    _memCache = result;
    _memCacheTs = DateTime.now();
    _saveToDisk(result).ignore();

    return result;
  }

  Future<void> _saveToDisk(List<OsmClub> clubs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(clubs.map((c) => c.toJson()).toList());
      await prefs.setString(_diskKey, encoded);
      await prefs.setInt(
          _diskTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // disk write failure is non-fatal
    }
  }

  /// Name search across Spain (nightclub + bar + pub).
  Future<List<OsmClub>> loadClubsByProvince(String osmName,
      {bool forceRefresh = false}) async {
    if (forceRefresh) {
      _provinceCache.remove(osmName);
      _provinceCacheTs.remove(osmName);
    }
    final cached = _provinceCache[osmName];
    final cachedTs = _provinceCacheTs[osmName];
    if (cached != null && cachedTs != null) {
      if (DateTime.now().difference(cachedTs) < _cacheDuration) return cached;
    }
    final diskKey =
        'overpass_province_${osmName.replaceAll(' ', '_').replaceAll('/', '_').toLowerCase()}_v1';
    final diskTsKey = '${diskKey}_ts';
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(diskKey);
      final ts = prefs.getInt(diskTsKey);
      if (raw != null && ts != null) {
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        if (age < _cacheDuration.inMilliseconds) {
          final list = (jsonDecode(raw) as List)
              .map((e) => OsmClub.fromJson(e as Map<String, dynamic>))
              .toList();
          _provinceCache[osmName] = list;
          _provinceCacheTs[osmName] = DateTime.fromMillisecondsSinceEpoch(ts);
          return list;
        }
      }
    } catch (_) {}
    final q = '''
[out:json][timeout:45];
area["name"="$osmName"]["admin_level"="6"]->.prov;
(
  node["amenity"="nightclub"](area.prov);
  way["amenity"="nightclub"](area.prov);
  relation["amenity"="nightclub"](area.prov);
);
out center;
''';
    final result = await _runQuery(q, timeout: const Duration(seconds: 60));
    _provinceCache[osmName] = result;
    _provinceCacheTs[osmName] = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          diskKey, jsonEncode(result.map((c) => c.toJson()).toList()));
      await prefs.setInt(diskTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
    return result;
  }

  Future<List<OsmClub>> searchClubs(String query) async {
    final escaped = query.replaceAll('"', '\\"').replaceAll('\\', '\\\\');
    final q = '''
[out:json][timeout:25];
area["ISO3166-1"="ES"]["admin_level"="2"]->.es;
(
  node["amenity"~"nightclub|bar|pub"]["name"~"$escaped",i](area.es);
  way["amenity"~"nightclub|bar|pub"]["name"~"$escaped",i](area.es);
  relation["amenity"~"nightclub|bar|pub"]["name"~"$escaped",i](area.es);
);
out center 60;
''';
    return _runQuery(q);
  }

  Future<List<OsmClub>> _runQuery(String query,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: 'data=${Uri.encodeComponent(query)}',
        )
        .timeout(timeout);

    if (response.statusCode == 429) {
      throw Exception('Overpass rate limit. Espera unos segundos e inténtalo de nuevo.');
    }
    if (response.statusCode != 200) {
      throw Exception('Overpass error ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List<dynamic>?) ?? [];

    final clubs = <OsmClub>[];
    for (final e in elements) {
      try {
        final club = OsmClub.fromElement(e as Map<String, dynamic>);
        if (club.name != 'Sin nombre') clubs.add(club);
      } catch (_) {
        // skip elements without coordinates
      }
    }
    return clubs;
  }
}

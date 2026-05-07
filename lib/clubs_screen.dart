import 'package:afterlife_projects/components/animations/animated_entry.dart';
import 'package:afterlife_projects/components/effects/glass_card.dart';
import 'package:afterlife_projects/osm_club_detail_screen.dart';
import 'package:afterlife_projects/services/overpass_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Province model ────────────────────────────────────────────────────────────

class _Province {
  final String name;
  final String osmName;
  final String emoji;
  const _Province(this.name, this.osmName, this.emoji);
}

const _provinces = [
  _Province('Álava', 'Araba/Álava', '🏔️'),
  _Province('Albacete', 'Albacete', '🌾'),
  _Province('Alicante', 'Alicante', '🏖️'),
  _Province('Almería', 'Almería', '☀️'),
  _Province('Asturias', 'Asturias', '🌿'),
  _Province('Ávila', 'Ávila', '🏰'),
  _Province('Badajoz', 'Badajoz', '🌻'),
  _Province('Barcelona', 'Barcelona', '🎆'),
  _Province('Burgos', 'Burgos', '🏛️'),
  _Province('Cáceres', 'Cáceres', '🦅'),
  _Province('Cádiz', 'Cádiz', '🌊'),
  _Province('Cantabria', 'Cantabria', '⛰️'),
  _Province('Castellón', 'Castelló/Castellón', '🍊'),
  _Province('Ciudad Real', 'Ciudad Real', '🍷'),
  _Province('Córdoba', 'Córdoba', '🕌'),
  _Province('A Coruña', 'A Coruña', '🐚'),
  _Province('Cuenca', 'Cuenca', '🏞️'),
  _Province('Girona', 'Girona', '🦁'),
  _Province('Granada', 'Granada', '🎸'),
  _Province('Guadalajara', 'Guadalajara', '🌄'),
  _Province('Gipuzkoa', 'Gipuzkoa', '🎣'),
  _Province('Huelva', 'Huelva', '🌅'),
  _Province('Huesca', 'Huesca', '❄️'),
  _Province('Jaén', 'Jaén', '🫒'),
  _Province('La Rioja', 'La Rioja', '🍇'),
  _Province('Las Palmas', 'Las Palmas', '🌴'),
  _Province('León', 'León', '🏰'),
  _Province('Lleida', 'Lleida', '🏔️'),
  _Province('Lugo', 'Lugo', '🌊'),
  _Province('Madrid', 'Madrid', '👑'),
  _Province('Málaga', 'Málaga', '🌞'),
  _Province('Murcia', 'Murcia', '🌶️'),
  _Province('Navarra', 'Navarra', '🐂'),
  _Province('Ourense', 'Ourense', '♨️'),
  _Province('Palencia', 'Palencia', '🏟️'),
  _Province('Pontevedra', 'Pontevedra', '⚓'),
  _Province('Salamanca', 'Salamanca', '🎓'),
  _Province('Santa Cruz de Tenerife', 'Santa Cruz de Tenerife', '🌋'),
  _Province('Segovia', 'Segovia', '🏰'),
  _Province('Sevilla', 'Sevilla', '💃'),
  _Province('Soria', 'Soria', '🌲'),
  _Province('Tarragona', 'Tarragona', '🍷'),
  _Province('Teruel', 'Teruel', '🐉'),
  _Province('Toledo', 'Toledo', '⚔️'),
  _Province('Valencia', 'Valencia', '🎇'),
  _Province('Valladolid', 'Valladolid', '🎭'),
  _Province('Bizkaia', 'Bizkaia', '🌉'),
  _Province('Zamora', 'Zamora', '🛡️'),
  _Province('Zaragoza', 'Zaragoza', '🎺'),
  _Province('Ceuta', 'Ceuta', '⚓'),
  _Province('Melilla', 'Melilla', '🌍'),
  _Province('Baleares', 'Illes Balears', '🏝️'),
];

// ── ClubsScreen (province grid) ───────────────────────────────────────────────

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Province> get _filtered {
    if (_query.isEmpty) return _provinces;
    final q = _query.toLowerCase();
    return _provinces.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar provincia…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Header text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      AfterlifeColors.electricPurple,
                      AfterlifeColors.neonPink,
                    ],
                  ).createShader(b),
                  child: const Text(
                    'ELIGE TU PROVINCIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} provincias',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final p = filtered[i];
                return AnimatedEntry(
                  delay: Duration(milliseconds: i * 30),
                  child: _ProvinceCard(
                    province: p,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _ProvinceClubsScreen(province: p),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Province card ─────────────────────────────────────────────────────────────

class _ProvinceCard extends StatelessWidget {
  final _Province province;
  final bool isDark;
  final VoidCallback onTap;

  const _ProvinceCard({
    required this.province,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              province.emoji,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                province.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Province clubs screen ─────────────────────────────────────────────────────

class _ProvinceClubsScreen extends StatefulWidget {
  final _Province province;
  const _ProvinceClubsScreen({required this.province});

  @override
  State<_ProvinceClubsScreen> createState() => _ProvinceClubsScreenState();
}

class _ProvinceClubsScreenState extends State<_ProvinceClubsScreen> {
  final _service = OverpassService();
  List<OsmClub>? _clubs;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final clubs = await _service.loadClubsByProvince(
        widget.province.osmName,
        forceRefresh: forceRefresh,
      );
      if (mounted) setState(() => _clubs = clubs);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text(widget.province.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              widget.province.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => _load(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AfterlifeColors.electricPurple,
            ),
            const SizedBox(height: 16),
            Text(
              'Buscando discotecas en ${widget.province.name}…',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'Error al cargar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final clubs = _clubs ?? [];

    if (clubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.province.emoji,
                style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Sin discotecas registradas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No hay locales en OpenStreetMap\npara ${widget.province.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: clubs.length,
      itemBuilder: (ctx, i) {
        final club = clubs[i];
        return AnimatedEntry(
          delay: Duration(milliseconds: i * 40),
          child: GlassCard(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AfterlifeColors.electricPurple,
                      AfterlifeColors.neonPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.nightlife,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: Text(
                club.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (club.address.isNotEmpty)
                    Text(
                      club.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  if (club.musicGenres.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: club.musicGenres.take(3).map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AfterlifeColors.electricPurple
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            g,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AfterlifeColors.electricPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AfterlifeColors.electricPurple,
              ),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OsmClubDetailScreen(club: club),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

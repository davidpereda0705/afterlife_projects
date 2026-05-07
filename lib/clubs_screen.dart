import 'package:afterlife_projects/components/effects/glass_card.dart';
import 'package:afterlife_projects/components/animations/animated_entry.dart';
import 'package:afterlife_projects/osm_club_detail_screen.dart';
import 'package:afterlife_projects/services/overpass_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

// ── Provincias de España ──────────────────────────────────────────────────────

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
  _Province('León', 'León', '🦁'),
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
  _Province('S.C. Tenerife', 'Santa Cruz de Tenerife', '🌋'),
  _Province('Segovia', 'Segovia', '🏰'),
  _Province('Sevilla', 'Sevilla', '💃'),
  _Province('Soria', 'Soria', '🌲'),
  _Province('Tarragona', 'Tarragona', '🏛️'),
  _Province('Teruel', 'Teruel', '🦕'),
  _Province('Toledo', 'Toledo', '⚔️'),
  _Province('Valencia', 'Valencia', '🎇'),
  _Province('Valladolid', 'Valladolid', '🏇'),
  _Province('Bizkaia', 'Bizkaia', '🌉'),
  _Province('Zamora', 'Zamora', '🐉'),
  _Province('Zaragoza', 'Zaragoza', '🎡'),
];

// ── Main screen ───────────────────────────────────────────────────────────────

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  List<_Province> get _filtered {
    if (_filter.isEmpty) return _provinces;
    final q = _filter.toLowerCase();
    return _provinces.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF06B6D4)],
                    ).createShader(b),
                    child: const Text(
                      'DISCOTECAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona una provincia',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withValues(alpha: 0.07),
                      border: Border.all(
                        color: _filter.isNotEmpty
                            ? AfterlifeColors.electricPurple.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _filter = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar provincia...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: _filter.isNotEmpty
                                ? AfterlifeColors.electricPurple
                                : Colors.white.withValues(alpha: 0.35),
                            size: 20),
                        suffixIcon: _filter.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 16, color: Colors.white.withValues(alpha: 0.4)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _filter = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final p = filtered[i];
                  return AnimatedEntry(
                    delay: Duration(milliseconds: 30 * i),
                    child: _ProvinceCard(
                      province: p,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _ProvinceClubsScreen(province: p),
                        ),
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

// ── Province card ─────────────────────────────────────────────────────────────

class _ProvinceCard extends StatelessWidget {
  final _Province province;
  final VoidCallback onTap;
  const _ProvinceCard({required this.province, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: BorderRadius.circular(16),
        border: BorderSide(
          color: AfterlifeColors.electricPurple.withValues(alpha: 0.25),
          width: 1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(province.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              province.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
  const _ProvinceClubsScreen({super.key, required this.province});

  @override
  State<_ProvinceClubsScreen> createState() => _ProvinceClubsScreenState();
}

class _ProvinceClubsScreenState extends State<_ProvinceClubsScreen> {
  final OverpassService _service = OverpassService();
  List<OsmClub> _clubs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final clubs = await _service.loadClubsByProvince(widget.province.osmName);
      if (mounted) setState(() { _clubs = clubs; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(widget.province.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              widget.province.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _clubs.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AfterlifeColors.electricPurple),
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
            ).createShader(b),
            child: Text(
              'Cargando discotecas en\n${widget.province.name}...',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: AfterlifeColors.neonPink.withValues(alpha: 0.6)),
            const SizedBox(height: 14),
            Text('No se pudo cargar.\nComprueba tu conexión.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]),
                ),
                child: const Text('Reintentar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nightlife, size: 60, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            'No hay discotecas en\n${widget.province.name}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _clubs.length,
      itemBuilder: (context, i) {
        final club = _clubs[i];
        return AnimatedEntry(
          delay: Duration(milliseconds: 40 * i),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OsmClubDetailScreen(club: club)),
              ),
              child: GlassCard(
                borderRadius: BorderRadius.circular(16),
                border: BorderSide(
                  color: AfterlifeColors.electricPurple.withValues(alpha: 0.2),
                  width: 1,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AfterlifeColors.electricPurple.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.nightlife, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (club.city != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 11,
                                      color: AfterlifeColors.electricPurple.withValues(alpha: 0.8)),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      club.address,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.45),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (club.musicGenres.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                children: club.musicGenres.take(3).map((g) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AfterlifeColors.electricPurple.withValues(alpha: 0.15),
                                    border: Border.all(
                                        color: AfterlifeColors.electricPurple.withValues(alpha: 0.3),
                                        width: 0.8),
                                  ),
                                  child: Text(g,
                                      style: const TextStyle(
                                          color: Color(0xFFA855F7), fontSize: 9, fontWeight: FontWeight.w600)),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: Colors.white.withValues(alpha: 0.25), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:afterlife_projects/osm_club_detail_screen.dart';
import 'package:afterlife_projects/services/overpass_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final MapController _mapController = MapController();
  final OverpassService _service = OverpassService();
  final TextEditingController _searchController = TextEditingController();

  List<OsmClub> _allClubs = [];
  List<OsmClub> _filteredClubs = [];
  OsmClub? _selectedClub;

  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  Timer? _debounce;

  // Spain center
  static const _spainCenter = LatLng(40.4168, -3.7038);

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final clubs = await _service.loadAllSpainClubs();
      if (mounted) {
        setState(() {
          _allClubs = clubs;
          _filteredClubs = clubs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el mapa.\nComprueba tu conexión.';
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _searchQuery = value);

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim().toLowerCase();
      setState(() {
        _filteredClubs = q.isEmpty
            ? _allClubs
            : _allClubs.where((c) {
                return c.name.toLowerCase().contains(q) ||
                    (c.city?.toLowerCase().contains(q) ?? false) ||
                    c.musicGenres.any((g) => g.toLowerCase().contains(q));
              }).toList();
        _selectedClub = null;
      });

      // If exactly one result, fly to it
      if (_filteredClubs.length == 1) {
        _mapController.move(
          LatLng(_filteredClubs.first.lat, _filteredClubs.first.lon),
          15,
        );
      }
    });
  }

  void _selectClub(OsmClub club) {
    setState(() => _selectedClub = club);
    _mapController.move(LatLng(club.lat, club.lon), 15);
  }

  List<Marker> get _markers => _filteredClubs.map((club) {
        final isSelected = _selectedClub?.id == club.id;
        return Marker(
          point: LatLng(club.lat, club.lon),
          width: isSelected ? 40 : 28,
          height: isSelected ? 40 : 28,
          child: GestureDetector(
            onTap: () => _selectClub(club),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isSelected
                      ? [const Color(0xFFEC4899), const Color(0xFFA855F7)]
                      : [
                          const Color(0xFFA855F7).withValues(alpha: 0.9),
                          const Color(0xFF7C3AED).withValues(alpha: 0.9),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected
                            ? const Color(0xFFEC4899)
                            : const Color(0xFFA855F7))
                        .withValues(alpha: isSelected ? 0.8 : 0.5),
                    blurRadius: isSelected ? 16 : 8,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Icon(
                Icons.nightlife,
                color: Colors.white,
                size: isSelected ? 20 : 14,
              ),
            ),
          ),
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ─── Map ─────────────────────────────────────────────────────────
        const Positioned.fill(child: ColoredBox(color: Color(0xFF0D0D1A))),
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _spainCenter,
            initialZoom: 6.0,
            minZoom: 4.0,
            maxZoom: 18.0,
            backgroundColor: const Color(0xFF0D0D1A),
            onTap: (_, __) => setState(() => _selectedClub = null),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.afterlife.projects',
              retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
            ),
            if (!_loading && _error == null)
              MarkerLayer(
                markers: _markers,
                rotate: false,
              ),
          ],
        ),

        // ─── Top bar ─────────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _filteredClubs = _allClubs;
                _selectedClub = null;
              });
            },
            clubCount: _filteredClubs.length,
            isLoading: _loading,
            isDark: isDark,
          ),
        ),

        // ─── Loading overlay ─────────────────────────────────────────────
        if (_loading)
          Positioned.fill(
            child: _LoadingOverlay(isDark: isDark),
          ),

        // ─── Error overlay ────────────────────────────────────────────────
        if (_error != null)
          Positioned.fill(
            child: _ErrorOverlay(
              message: _error!,
              onRetry: _loadAll,
              isDark: isDark,
            ),
          ),

        // ─── Selected club bottom sheet ───────────────────────────────────
        if (_selectedClub != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ClubBottomSheet(
              club: _selectedClub!,
              isDark: isDark,
              onClose: () => setState(() => _selectedClub = null),
              onDetail: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OsmClubDetailScreen(club: _selectedClub!),
                ),
              ),
            ),
          ),

        // ─── Recenter button ─────────────────────────────────────────────
        if (!_loading && _error == null)
          Positioned(
            right: 14,
            bottom: _selectedClub != null ? 240 : 100,
            child: _MapButton(
              icon: Icons.my_location,
              onTap: () => _mapController.move(_spainCenter, 6.0),
              isDark: isDark,
            ),
          ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Top search bar
// ────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int clubCount;
  final bool isLoading;
  final bool isDark;

  const _TopBar({
    required this.searchController,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    required this.clubCount,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                    ).createShader(b),
                    child: const Text(
                      'CLUBS EN ESPAÑA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AfterlifeColors.electricPurple.withValues(alpha: 0.25),
                        border: Border.all(
                          color: AfterlifeColors.electricPurple.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '$clubCount clubs',
                        style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Search field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.black.withValues(alpha: 0.75),
                  border: Border.all(
                    color: searchQuery.isNotEmpty
                        ? AfterlifeColors.electricPurple.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.12),
                    width: searchQuery.isNotEmpty ? 1.5 : 1,
                  ),
                  boxShadow: searchQuery.isNotEmpty
                      ? [
                          BoxShadow(
                            color: AfterlifeColors.electricPurple
                                .withValues(alpha: 0.2),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar: Wolf, Razzmatazz, Fabrik...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: searchQuery.isNotEmpty
                          ? AfterlifeColors.electricPurple
                          : Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.5)),
                            onPressed: onClear,
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
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Loading overlay
// ────────────────────────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  final bool isDark;
  const _LoadingOverlay({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0D0D1A),
            border: Border.all(
              color: AfterlifeColors.electricPurple.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AfterlifeColors.electricPurple.withValues(alpha: 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    AfterlifeColors.electricPurple,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                ).createShader(b),
                child: const Text(
                  'Cargando discotecas...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Buscando en toda España',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Error overlay
// ────────────────────────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorOverlay(
      {required this.message, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0D0D1A),
            border: Border.all(
                color: AfterlifeColors.neonPink.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_outlined,
                  size: 48,
                  color: AfterlifeColors.neonPink.withValues(alpha: 0.6)),
              const SizedBox(height: 14),
              Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                    ),
                  ),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Selected club bottom sheet
// ────────────────────────────────────────────────────────────────────────────

class _ClubBottomSheet extends StatelessWidget {
  final OsmClub club;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  const _ClubBottomSheet({
    required this.club,
    required this.isDark,
    required this.onClose,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + close
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (club.city != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 12,
                                    color: AfterlifeColors.electricPurple
                                        .withValues(alpha: 0.8)),
                                const SizedBox(width: 3),
                                Text(
                                  club.address,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: Icon(Icons.close,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Genre chips
                if (club.musicGenres.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: club.musicGenres.take(4).map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AfterlifeColors.electricPurple
                              .withValues(alpha: 0.15),
                          border: Border.all(
                            color: AfterlifeColors.electricPurple
                                .withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: Color(0xFFA855F7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (club.openingHours != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.35)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          club.openingHours!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // Action button
                GestureDetector(
                  onTap: onDetail,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AfterlifeColors.electricPurple
                              .withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Ver info y entradas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Floating map button
// ────────────────────────────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _MapButton(
      {required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0D0D1A),
          border: Border.all(
            color: AfterlifeColors.electricPurple.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon,
            color: AfterlifeColors.electricPurple.withValues(alpha: 0.9),
            size: 20),
      ),
    );
  }
}

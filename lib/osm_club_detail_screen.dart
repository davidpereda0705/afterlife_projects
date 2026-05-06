import 'package:afterlife_projects/services/overpass_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OsmClubDetailScreen extends StatelessWidget {
  final OsmClub club;
  const OsmClubDetailScreen({super.key, required this.club});

  static const _colors = [Color(0xFFA855F7), Color(0xFF7C3AED)];

  Future<void> _launch(BuildContext context, String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede abrir el enlace')),
      );
    }
  }

  Future<void> _openMaps(BuildContext context) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${club.lat},${club.lon}';
    await _launch(context, url);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060610) : const Color(0xFFF8F5FF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (club.musicGenres.isNotEmpty) ...[
                    _buildGenreChips(isDark),
                    const SizedBox(height: 20),
                  ],
                  _buildInfoCards(context, isDark),
                  const SizedBox(height: 24),
                  if (club.description != null) ...[
                    _buildDescription(isDark),
                    const SizedBox(height: 24),
                  ],
                  _buildActionButtons(context, isDark),
                  const SizedBox(height: 12),
                  _buildMapsButton(context, isDark),
                  if (club.instagram != null) ...[
                    const SizedBox(height: 16),
                    _buildInstagramLink(context, isDark),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
          ),
          child: Icon(
            Icons.arrow_back,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF1A0A2E),
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colors[0].withValues(alpha: isDark ? 0.35 : 0.2),
                    _colors[1].withValues(alpha: isDark ? 0.15 : 0.08),
                    isDark ? const Color(0xFF060610) : const Color(0xFFF8F5FF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _BubblePainter(_colors[0].withValues(alpha: 0.06)),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: _colors,
                    ).createShader(b),
                    child: Text(
                      club.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 13,
                          color: _colors[0].withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          club.address,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF6B5B7F),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: club.musicGenres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _colors[0].withValues(alpha: isDark ? 0.15 : 0.1),
            border: Border.all(color: _colors[0].withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note, size: 12, color: _colors[0]),
              const SizedBox(width: 4),
              Text(
                genre,
                style: TextStyle(
                  color: _colors[0],
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCards(BuildContext context, bool isDark) {
    final items = <(IconData, String, String)>[
      if (club.openingHours != null)
        (Icons.schedule_outlined, 'Horario', club.openingHours!),
      if (club.city != null)
        (Icons.location_city_outlined, 'Ciudad', club.city!),
      if (club.phone != null)
        (Icons.phone_outlined, 'Teléfono', club.phone!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: items.length == 1 ? 1 : 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFE8E0F0),
            ),
          ),
          child: Row(
            children: [
              Icon(item.$1, size: 16, color: _colors[0]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : const Color(0xFFB0A8BC),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      item.$3,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre el club',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A0A2E),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          club.description!,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.65)
                : const Color(0xFF4A3B5A),
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    if (club.website == null) {
      return _buildNoWebsiteNote(isDark);
    }

    return GestureDetector(
      onTap: () => _launch(context, club.website),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: _colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _colors[0].withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Visitar Web Oficial',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWebsiteNote(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE8E0F0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : const Color(0xFFB0A8BC)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No hay web registrada para este club. Búscalo en redes o Google.',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFF6B5B7F),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _openMaps(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(color: _colors[0].withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: _colors[0], size: 20),
            const SizedBox(width: 10),
            Text(
              'Ver en Google Maps',
              style: TextStyle(
                color: _colors[0],
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramLink(BuildContext context, bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () => _launch(context, club.instagram),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFFB0A8BC)),
            const SizedBox(width: 6),
            Text(
              'Ver en Instagram',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFFB0A8BC),
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  _BubblePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.25), 70, p);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.65), 45, p);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color;
}

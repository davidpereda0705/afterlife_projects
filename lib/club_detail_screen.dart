import 'package:afterlife_projects/models/club_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubDetailScreen extends StatelessWidget {
  final Club club;

  const ClubDetailScreen({super.key, required this.club});

  static const _gradients = {
    'purple': [Color(0xFFA855F7), Color(0xFF7C3AED)],
    'pink': [Color(0xFFEC4899), Color(0xFFBE185D)],
    'cyan': [Color(0xFF06B6D4), Color(0xFF0284C7)],
    'orange': [Color(0xFFF59E0B), Color(0xFFEF4444)],
  };

  Future<void> _launch(BuildContext context, String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _gradients[club.gradientKey] ?? _gradients['purple'] ?? [const Color(0xFFA855F7), const Color(0xFF7C3AED)];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060610) : const Color(0xFFF8F5FF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, colors, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGenreChips(colors, isDark),
                  const SizedBox(height: 20),
                  _buildInfoGrid(colors, isDark),
                  const SizedBox(height: 24),
                  _buildDescription(isDark),
                  const SizedBox(height: 20),
                  if (club.tags.isNotEmpty) _buildTags(colors, isDark),
                  if (club.tags.isNotEmpty) const SizedBox(height: 28),
                  _buildActionButtons(context, colors, isDark),
                  const SizedBox(height: 16),
                  if (club.instagramUrl != null)
                    _buildInstagramButton(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, List<Color> colors, bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
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
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors[0].withValues(alpha: isDark ? 0.4 : 0.25),
                    colors[1].withValues(alpha: isDark ? 0.2 : 0.1),
                    isDark ? const Color(0xFF060610) : const Color(0xFFF8F5FF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Abstract pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _CirclePainter(colors[0].withValues(alpha: 0.07)),
              ),
            ),
            // Club name bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [colors[0], colors[1]],
                    ).createShader(b),
                    child: Text(
                      club.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
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
                          color: colors[0].withValues(alpha: 0.8)),
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

  Widget _buildGenreChips(List<Color> colors, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: club.musicGenres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                colors[0].withValues(alpha: 0.15),
                colors[1].withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: colors[0].withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note, size: 12, color: colors[0]),
              const SizedBox(width: 4),
              Text(
                genre,
                style: TextStyle(
                  color: colors[0],
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

  Widget _buildInfoGrid(List<Color> colors, bool isDark) {
    final items = [
      (Icons.schedule_outlined, 'Horario', club.schedule),
      (Icons.euro_outlined, 'Precio', club.priceRange),
      (Icons.people_outline, 'Aforo', '${club.capacity} personas'),
      (Icons.location_city_outlined, 'Ciudad', club.city),
    ];

    return GridView.count(
      crossAxisCount: 2,
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFE8E0F0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(item.$1, size: 16, color: colors[0]),
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
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          club.description,
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

  Widget _buildTags(List<Color> colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destacado',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A0A2E),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: club.tags.map((tag) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: colors),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tag,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : const Color(0xFF4A3B5A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, List<Color> colors, bool isDark) {
    return Column(
      children: [
        if (club.ticketsUrl != null)
          _PrimaryButton(
            label: 'Comprar Entradas',
            icon: Icons.confirmation_number_outlined,
            colors: colors,
            onTap: () => _launch(context, club.ticketsUrl),
          ),
        if (club.ticketsUrl != null && club.websiteUrl != null)
          const SizedBox(height: 12),
        if (club.websiteUrl != null)
          _SecondaryButton(
            label: 'Visitar Web Oficial',
            icon: Icons.language,
            colors: colors,
            isDark: isDark,
            onTap: () => _launch(context, club.websiteUrl),
          ),
      ],
    );
  }

  Widget _buildInstagramButton(BuildContext context, bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () => _launch(context, club.instagramUrl),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFFB0A8BC),
            ),
            const SizedBox(width: 6),
            Text(
              'Ver en Instagram',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.45)
                    : const Color(0xFFB0A8BC),
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : const Color(0xFFB0A8BC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Buttons
// ────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
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
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final bool isDark;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
          border: Border.all(
            color: colors[0].withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors[0], size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: colors[0],
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Decorative background painter
// ────────────────────────────────────────────────────────────────────────────

class _CirclePainter extends CustomPainter {
  final Color color;
  _CirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.7), 50, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.8), 30, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.color != color;
}

// Pantalla de ajustes: modo oscuro, modo compacto, preferencias de notificaciones y cuenta.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:afterlife_projects/providers/settings_provider.dart';
import 'package:afterlife_projects/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
          ).createShader(bounds),
          child: const Text(
            'AJUSTES',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _buildSection(
            label: 'Apariencia',
            icon: Icons.palette_outlined,
            color: AfterlifeColors.electricPurple,
            isDark: isDark,
            children: [
              _ThemeSelector(
                current: settings.themeModeKey,
                onChanged: (key) => settings.setThemeMode(key),
              ),
              _divider(isDark),
              _FontSizeRow(settings: settings, isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            label: 'Cuenta',
            icon: Icons.person_outline,
            color: AfterlifeColors.acidGreen,
            isDark: isDark,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AfterlifeColors.electricPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined, color: AfterlifeColors.electricPurple, size: 18),
                ),
                title: Text(
                  'Editar perfil',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white24 : Colors.black26),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.25 : 0.2),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        thickness: 1,
        indent: 56,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      );
}

class _ThemeSelector extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;

  const _ThemeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const options = [
      (key: 'dark', icon: Icons.dark_mode, label: 'Oscuro'),
      (key: 'system', icon: Icons.brightness_auto, label: 'Sistema'),
      (key: 'light', icon: Icons.light_mode, label: 'Claro'),
    ];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  size: 20,
                  color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54),
              const SizedBox(width: 10),
              Text('Tema',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: options.map((opt) {
              final isSelected = current == opt.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AfterlifeColors.electricPurple, AfterlifeColors.neonPink],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(opt.icon, size: 20,
                            color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45)),
                        const SizedBox(height: 5),
                        Text(opt.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FontSizeRow extends StatelessWidget {
  final SettingsProvider settings;
  final bool isDark;

  const _FontSizeRow({required this.settings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = (settings.fontSizeFactor * 100).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_size, size: 20, color: AfterlifeColors.electricPurple),
              const SizedBox(width: 10),
              Text('Tamaño de letra',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AfterlifeColors.electricPurple.withValues(alpha: 0.4)),
                ),
                child: Text('$pct%',
                    style: const TextStyle(
                      color: AfterlifeColors.electricPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Afterlife — la mejor app de noches',
              style: TextStyle(
                fontSize: 14 * settings.fontSizeFactor,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: settings.fontSizeFactor,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              activeColor: AfterlifeColors.electricPurple,
              onChanged: (v) {
                settings.setFontSizeFactor(v);
                HapticFeedback.selectionClick();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pequeño', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
              Text('Normal', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
              Text('Grande', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ],
      ),
    );
  }
}

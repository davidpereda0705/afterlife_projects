import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:afterlife_projects/providers/settings_provider.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<UserProvider>();
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
                onChanged: (key) {
                  settings.setThemeMode(key);
                  _haptic(settings);
                },
              ),
              _divider(isDark),
              _FontSizeRow(settings: settings, isDark: isDark),
              _divider(isDark),
              _ToggleRow(
                icon: Icons.auto_awesome,
                iconColor: AfterlifeColors.neonPink,
                label: 'Efectos de fondo',
                subtitle: 'Partículas y animaciones en el fondo',
                value: settings.backgroundEffects,
                isDark: isDark,
                onChanged: (v) {
                  settings.setBackgroundEffects(v);
                  _haptic(settings);
                },
              ),
              _divider(isDark),
              _ToggleRow(
                icon: Icons.view_compact_outlined,
                iconColor: AfterlifeColors.cyanBlue,
                label: 'Modo compacto',
                subtitle: 'Reduce el espaciado entre elementos',
                value: settings.compactMode,
                isDark: isDark,
                onChanged: (v) {
                  settings.setCompactMode(v);
                  _haptic(settings);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            label: 'Sistema',
            icon: Icons.settings_outlined,
            color: AfterlifeColors.cyanBlue,
            isDark: isDark,
            children: [
              _ToggleRow(
                icon: Icons.vibration,
                iconColor: AfterlifeColors.acidGreen,
                label: 'Vibración táctil',
                subtitle: 'Feedback háptico en acciones',
                value: settings.hapticFeedback,
                isDark: isDark,
                onChanged: (v) {
                  settings.setHapticFeedback(v);
                  if (v) HapticFeedback.lightImpact();
                },
              ),
              _divider(isDark),
              _ToggleRow(
                icon: Icons.notifications_outlined,
                iconColor: AfterlifeColors.neonOrange,
                label: 'Notificaciones',
                subtitle: 'Avisos de amigos y noches activas',
                value: settings.notificationsEnabled,
                isDark: isDark,
                onChanged: (v) {
                  settings.setNotificationsEnabled(v);
                  _haptic(settings);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            label: 'Cuenta',
            icon: Icons.person_outline,
            color: AfterlifeColors.acidGreen,
            isDark: isDark,
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                iconColor: AfterlifeColors.electricPurple,
                label: 'Usuario',
                value: user.userData?['username'] ?? '–',
                isDark: isDark,
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
              _divider(isDark),
              _InfoRow(
                icon: Icons.email_outlined,
                iconColor: AfterlifeColors.cyanBlue,
                label: 'Email',
                value: FirebaseAuth.instance.currentUser?.email ?? '–',
                isDark: isDark,
                onTap: () => _showChangeEmailDialog(),
              ),
              _divider(isDark),
              _ActionRow(
                icon: Icons.logout,
                iconColor: AfterlifeColors.neonOrange,
                label: 'Cerrar sesión',
                isDark: isDark,
                onTap: () => _showSignOutDialog(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            label: 'Soporte',
            icon: Icons.help_outline,
            color: AfterlifeColors.neonPink,
            isDark: isDark,
            children: [
              _ActionRow(
                icon: Icons.help_outline,
                iconColor: AfterlifeColors.cyanBlue,
                label: 'Centro de ayuda',
                isDark: isDark,
                onTap: () {},
              ),
              _divider(isDark),
              _ActionRow(
                icon: Icons.support_agent,
                iconColor: AfterlifeColors.acidGreen,
                label: 'Contactar soporte',
                isDark: isDark,
                onTap: () {},
              ),
              _divider(isDark),
              _ActionRow(
                icon: Icons.info_outline,
                iconColor: AfterlifeColors.electricPurple,
                label: 'Versión de la app',
                trailing: const Text('1.0.0',
                    style: TextStyle(
                        color: AfterlifeColors.electricPurple,
                        fontWeight: FontWeight.w600)),
                isDark: isDark,
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            label: 'Zona de peligro',
            icon: Icons.warning_amber_outlined,
            color: Colors.redAccent,
            isDark: isDark,
            children: [
              _ActionRow(
                icon: Icons.delete_forever,
                iconColor: Colors.redAccent,
                label: 'Eliminar cuenta',
                labelColor: Colors.redAccent,
                isDark: isDark,
                onTap: () => _showDeleteAccountDialog(),
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

  void _haptic(SettingsProvider s) {
    if (s.hapticFeedback) HapticFeedback.selectionClick();
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a iniciar sesión.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('CERRAR SESIÓN'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
            'Esta acción es irreversible y perderás todos tus logros y progreso.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount();
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final ctrl = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.email ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar email'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nuevo email'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.currentUser
                    ?.verifyBeforeUpdateEmail(ctrl.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Email actualizado. Verifica tu bandeja.')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e\n(Puede que necesites re-autenticarte)'),
            backgroundColor: AfterlifeColors.neonOrange,
          ),
        );
      }
    }
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black54),
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
                              colors: [
                                AfterlifeColors.electricPurple,
                                AfterlifeColors.neonPink,
                              ],
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
                        Icon(
                          opt.icon,
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white54
                                  : Colors.black45),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white54
                                    : Colors.black45),
                          ),
                        ),
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
              Icon(Icons.format_size,
                  size: 20,
                  color: AfterlifeColors.electricPurple),
              const SizedBox(width: 10),
              Text('Tamaño de letra',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AfterlifeColors.electricPurple
                      .withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AfterlifeColors.electricPurple
                          .withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(
                    color: AfterlifeColors.electricPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Live preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
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
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: settings.fontSizeFactor,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              activeColor: AfterlifeColors.electricPurple,
              onChanged: (v) {
                settings.setFontSizeFactor(v);
                if (settings.hapticFeedback) HapticFeedback.selectionClick();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pequeño',
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38)),
              Text('Normal',
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38)),
              Text('Grande',
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final bool isDark;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          )),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor:
            AfterlifeColors.electricPurple.withValues(alpha: 0.4),
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AfterlifeColors.electricPurple
                : null),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          )),
      subtitle: Text(value,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black45,
          )),
      trailing: onTap != null
          ? Icon(Icons.chevron_right,
              size: 20, color: isDark ? Colors.white24 : Colors.black26)
          : null,
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final bool isDark;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
    this.labelColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right,
                  size: 20,
                  color: isDark ? Colors.white24 : Colors.black26)
              : null),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:afterlife_projects/providers/settings_provider.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEditingEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Apariencia', colorScheme),
          AfterlifeCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildThemeOption(
                        context,
                        icon: Icons.dark_mode,
                        label: 'Oscuro',
                        value: 'dark',
                        groupValue: settingsProvider.themeModeKey,
                        onTap: () => settingsProvider.setThemeMode(ThemeMode.dark),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        context,
                        icon: Icons.light_mode,
                        label: 'Claro',
                        value: 'light',
                        groupValue: settingsProvider.themeModeKey,
                        onTap: () => settingsProvider.setThemeMode(ThemeMode.light),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),
                ListTile(
                  title: const Text('Tamaño de letra'),
                  subtitle: Text('${(settingsProvider.fontSizeFactor * 100).toInt()}%'),
                  leading: Icon(Icons.format_size, color: colorScheme.secondary),
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(
                      value: settingsProvider.fontSizeFactor,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      onChanged: (value) {
                        settingsProvider.setFontSizeFactor(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Cuenta', colorScheme),
          AfterlifeCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Email'),
                  subtitle: _isEditingEmail
                    ? TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Nuevo email',
                          isDense: true,
                        ),
                      )
                    : Text(_emailController.text),
                  leading: Icon(Icons.email_outlined, color: colorScheme.secondary),
                  trailing: IconButton(
                    icon: Icon(_isEditingEmail ? Icons.check : Icons.edit, 
                      color: colorScheme.secondary),
                    onPressed: () async {
                      if (_isEditingEmail) {
                        await _updateEmail();
                      } else {
                        setState(() => _isEditingEmail = true);
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),
                ListTile(
                  title: const Text('Cambiar nombre'),
                  subtitle: Text(userProvider.userData?['username'] ?? 'Cargando...'),
                  leading: Icon(Icons.person_outline, color: AfterlifeColors.acidGreen),
                  onTap: () {
                    Navigator.pushNamed(context, '/edit-profile');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Soporte', colorScheme),
          AfterlifeCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Centro de ayuda'),
                  leading: Icon(Icons.help_outline, color: AfterlifeColors.cyanBlue),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                Divider(height: 1, color: theme.dividerColor),
                ListTile(
                  title: const Text('Contactar soporte'),
                  leading: Icon(Icons.support_agent, color: AfterlifeColors.acidGreen),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Zona de Peligro', colorScheme),
          AfterlifeCard(
            child: ListTile(
              title: Text('Eliminar cuenta', style: TextStyle(color: colorScheme.error)),
              leading: Icon(Icons.delete_forever, color: colorScheme.error),
              onTap: () => _showDeleteAccountDialog(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AfterlifeColors.electricPurple,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text('Esta acción es irreversible y perderás todos tus logros y progreso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount();
            },
            child: const Text('ELIMINAR DEFINITIVAMENTE'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.delete();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e (Probablemente necesites re-autenticarte)'),
              backgroundColor: AfterlifeColors.neonOrange,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email actualizado. Por favor verifica tu bandeja de entrada.'),
            backgroundColor: AfterlifeColors.acidGreen,
          ),
        );
        setState(() => _isEditingEmail = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AfterlifeColors.neonOrange),
        );
      }
    }
  }
}

// Pantalla para editar el perfil del usuario: nombre, handle, foto de perfil
// y cambio de contraseña. La foto se comprime y guarda como bytes en Firestore.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afterlife_projects/widgets/common/afterlife_avatar.dart';
import 'package:afterlife_projects/widgets/cards/afterlife_card.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _handleController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _hasChanges = false;
  bool _showPasswordSection = false;
  bool _isSaving = false;
  bool _initialized = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _handleController = TextEditingController();
    _nameController.addListener(_onChange);
    _handleController.addListener(_onChange);
  }

  void _onChange() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _populateControllers(Map<String, dynamic>? userData, String email) {
    if (_initialized) return;
    final userName = userData?['username'] ?? email.split('@').first;
    final userHandle =
        userData?['handle'] ?? '@${userName.toLowerCase().replaceAll(' ', '')}';
    _nameController.text = userName;
    _handleController.text = userHandle;
    _initialized = true;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildSourceOption(
              icon: Icons.photo_library,
              label: 'Elegir de la galería',
              color: AfterlifeColors.cyanBlue,
              source: ImageSource.gallery,
            ),
            _buildSourceOption(
              icon: Icons.camera_alt,
              label: 'Tomar foto',
              color: AfterlifeColors.neonPink,
              source: ImageSource.camera,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (source != null) {
      setState(() => _isUploading = true);
      try {
        final pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 500,
        );
        if (pickedFile != null) {
          setState(() {
            _avatarImage = File(pickedFile.path);
            _hasChanges = true;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto actualizada localmente. Guarda los cambios.'),
              backgroundColor: AfterlifeColors.acidGreen,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar la imagen'),
            backgroundColor: AfterlifeColors.neonOrange,
          ),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
   title: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      onTap: () => Navigator.pop(context, source),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Descartar cambios',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          '¿Seguro que quieres salir sin guardar?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AfterlifeColors.neonOrange,
            ),
            child: const Text('DESCARTAR'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveProfileChanges(UserProvider userProvider) async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackbar(
        'El nombre no puede estar vacío',
        AfterlifeColors.neonOrange,
      );
      return;
    }
    String handle = _handleController.text.trim();
    if (!handle.startsWith('@') || handle.length < 2) {
      _showSnackbar(
        'El handle debe empezar con @ y tener al menos un carácter',
        AfterlifeColors.neonOrange,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await userProvider.updateUserProfile(
        username: _nameController.text.trim(),
        handle: _handleController.text.trim(),
        avatarFile: _avatarImage,
      );
      _showSnackbar('Perfil actualizado', AfterlifeColors.acidGreen);
      setState(() => _hasChanges = false);
    } catch (e) {
      _showSnackbar('Error al guardar: $e', AfterlifeColors.neonOrange);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword(AuthService authService) async {
    if (_currentPasswordController.text.isEmpty) {
      _showSnackbar(
        'Introduce tu contraseña actual',
        AfterlifeColors.neonOrange,
      );
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnackbar(
        'La nueva contraseña debe tener al menos 6 caracteres',
        AfterlifeColors.neonOrange,
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackbar('Las contraseñas no coinciden', AfterlifeColors.neonOrange);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await authService.changePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
      _showSnackbar('Contraseña actualizada', AfterlifeColors.acidGreen);
      setState(() {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showPasswordSection = false;
      });
    } catch (e) {
      _showSnackbar(
        'Error al cambiar contraseña: $e',
        AfterlifeColors.neonOrange,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Convierte el campo avatarBytes de Firestore a Uint8List
  Uint8List? _toBytes(dynamic raw) {
    if (raw == null) return null;
    if (raw is Uint8List) return raw;
    if (raw is List) return Uint8List.fromList(raw.cast<int>());
    return null;
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading && !_initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (userProvider.error != null && !_initialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar perfil: ${userProvider.error}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final userData = userProvider.userData;
        final currentUser = FirebaseAuth.instance.currentUser;
        final email = currentUser?.email ?? '';
        _populateControllers(userData, email);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) Navigator.pop(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () async {
                  if (await _onWillPop() && context.mounted) Navigator.pop(context);
                },
              ),
              title: Text(
                'Editar Perfil',
                style: AfterlifeTextTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AfterlifeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                if (_isUploading)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            AfterlifeColors.electricLilac,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  AfterlifeAvatar(
                                    // Previsualización local si hay imagen nueva, si no los bytes guardados
                                    imageUrl: _avatarImage?.path,
                                    imageBytes: _toBytes(userData?['avatarBytes']),
                                    initials: _nameController.text.isNotEmpty
                                        ? _nameController.text[0].toUpperCase()
                                        : 'U',
                                    status: AvatarStatus.online,
                                    size: 100,
                                    showStatusIndicator: false,
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _isUploading || _isSaving
                                        ? null
                                        : _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AfterlifeColors.electricLilac,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: (_isUploading || _isSaving)
                                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
                                            : Theme.of(context).colorScheme.onSurface,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: (_isUploading || _isSaving)
                                  ? null
                                  : _pickImage,
                              child: Text(
                                'Cambiar foto de perfil',
                                style: TextStyle(
                                  color: (_isUploading || _isSaving)
                                      ? Theme.of(context).disabledColor
                                      : AfterlifeColors.cyanBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Información personal
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'INFORMACIÓN PERSONAL',
                          style: TextStyle(
                            color: AfterlifeColors.electricLilac,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      _buildField(
                        icon: Icons.person_outline,
                        label: 'Nombre',
                        controller: _nameController,
                        color: AfterlifeColors.electricLilac,
                      ),
            Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                      _buildField(
                        icon: Icons.alternate_email,
                        label: 'Handle',
                        controller: _handleController,
                        color: AfterlifeColors.neonPink,
                      ),

                      const SizedBox(height: 16),
            Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),

                      // Sección contraseña (colapsable)
                      InkWell(
                        onTap: () => setState(
                          () => _showPasswordSection = !_showPasswordSection,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                _showPasswordSection
                                    ? Icons.lock_open
                                    : Icons.lock_outline,
                                color: AfterlifeColors.neonPink,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'CAMBIAR CONTRASEÑA',
                                style: TextStyle(
                                  color: AfterlifeColors.neonPink,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _showPasswordSection
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showPasswordSection) ...[
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          label: 'Contraseña actual',
                          controller: _currentPasswordController,
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          label: 'Nueva contraseña',
                          controller: _newPasswordController,
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          label: 'Confirmar contraseña',
                          controller: _confirmPasswordController,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving
                                ? null
                                : () => _changePassword(_authService),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AfterlifeColors.neonPink,
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  )
                                : const Text(
                                    'ACTUALIZAR CONTRASEÑA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Botón guardar cambios
                      OutlinedButton.icon(
                        onPressed: (_hasChanges && !_isSaving)
                            ? () => _saveProfileChanges(userProvider)
                            : null,
                        icon: Icon(
                          Icons.check_circle,
                          color: (_hasChanges && !_isSaving)
                              ? AfterlifeColors.acidGreen
                              : Theme.of(context).disabledColor,
                        ),
                        label: Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            color: (_hasChanges && !_isSaving)
                                ? AfterlifeColors.acidGreen
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: (_hasChanges && !_isSaving)
                                ? AfterlifeColors.acidGreen.withValues(alpha: 0.5)
                                : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => _onChange(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AfterlifeColors.neonPink.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: true,
     style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

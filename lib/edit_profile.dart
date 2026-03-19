// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';



class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Carlos');
  final TextEditingController _handleController = TextEditingController(text: '@carlos_after');
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _hasChanges = false;
  bool _showPasswordSection = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onChange);
    _handleController.addListener(_onChange);
  }

  void _onChange() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AfterlifeColors.surfaceDark,
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
                color: Colors.white24,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto actualizada'),
              backgroundColor: AfterlifeColors.acidGreen,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la imagen'),
            backgroundColor: AfterlifeColors.neonOrange,
          ),
        );
      } finally {
        setState(() => _isUploading = false);
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
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => Navigator.pop(context, source),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AfterlifeColors.surfaceDark,
        title: const Text('Descartar cambios', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres salir sin guardar?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: AfterlifeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AfterlifeColors.neonOrange),
            child: const Text('DESCARTAR'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _saveProfileChanges() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El nombre no puede estar vacío'),
          backgroundColor: AfterlifeColors.neonOrange,
        ),
      );
      return;
    }
    if (!_handleController.text.startsWith('@') || _handleController.text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El handle debe empezar con @ y tener al menos un carácter'),
          backgroundColor: AfterlifeColors.neonOrange,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil actualizado'),
        backgroundColor: AfterlifeColors.acidGreen,
      ),
    );
    setState(() => _hasChanges = false);
  }

  void _changePassword() {
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Introduce tu contraseña actual'),
          backgroundColor: AfterlifeColors.neonOrange,
        ),
      );
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La nueva contraseña debe tener al menos 6 caracteres'),
          backgroundColor: AfterlifeColors.neonOrange,
        ),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Las contraseñas no coinciden'),
          backgroundColor: AfterlifeColors.neonOrange,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contraseña actualizada'),
        backgroundColor: AfterlifeColors.acidGreen,
      ),
    );
    setState(() {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showPasswordSection = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AfterlifeColors.background,
        appBar: AppBar(
          backgroundColor: AfterlifeColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AfterlifeColors.textPrimary),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          title: Text(
            'Editar Perfil',
            style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
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
                                  color: Colors.white10,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Color(0xFF7B1FA2)),
                                    ),
                                  ),
                                ),
                              )
                            else
                              AfterlifeAvatar(
                                imageUrl: _avatarImage?.path,
                                initials: 'CR',
                                status: AvatarStatus.online,
                                size: 100,
                                showStatusIndicator: false,
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploading ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AfterlifeColors.electricLilac,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AfterlifeColors.background, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: _isUploading ? Colors.white38 : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isUploading ? null : _pickImage,
                          child: Text(
                            'Cambiar foto de perfil',
                            style: TextStyle(
                              color: _isUploading ? AfterlifeColors.textDisabled : AfterlifeColors.cyanBlue,
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
                  const Divider(height: 24, color: Colors.white10),
                  _buildField(
                    icon: Icons.alternate_email,
                    label: 'Handle',
                    controller: _handleController,
                    color: AfterlifeColors.neonPink,
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 24, color: Colors.white10),

                  // Sección contraseña (colapsable)
                  InkWell(
                    onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _showPasswordSection ? Icons.lock_open : Icons.lock_outline,
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
                            _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                            color: AfterlifeColors.textSecondary,
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
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AfterlifeColors.neonPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('ACTUALIZAR CONTRASEÑA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Botón guardar cambios
                  OutlinedButton.icon(
                    onPressed: _hasChanges ? _saveProfileChanges : null,
                    icon: Icon(
                      Icons.check_circle,
                      color: _hasChanges ? AfterlifeColors.acidGreen : AfterlifeColors.textDisabled,
                    ),
                    label: Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(
                        color: _hasChanges ? AfterlifeColors.acidGreen : AfterlifeColors.textDisabled,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _hasChanges
                            ? AfterlifeColors.acidGreen.withOpacity(0.5)
                            : AfterlifeColors.textDisabled.withOpacity(0.3),
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
        Container(margin: const EdgeInsets.only(top: 12), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildPasswordField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AfterlifeColors.neonPink.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
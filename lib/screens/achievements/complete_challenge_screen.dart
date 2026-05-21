// lib/screens/complete_challenge_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/widgets/common/after_button.dart';
import 'package:afterlife_projects/widgets/common/afterlife_avatar.dart';
import 'package:afterlife_projects/utils/image_utils.dart';

class CompleteChallengeScreen extends StatefulWidget {
  final Map<String, dynamic> challenge;
  final List<Map<String, dynamic>> players;

  const CompleteChallengeScreen({
    super.key,
    required this.challenge,
    required this.players,
  });

  @override
  State<CompleteChallengeScreen> createState() => _CompleteChallengeScreenState();
}

class _CompleteChallengeScreenState extends State<CompleteChallengeScreen> {
  String? _selectedPlayer;
  Uint8List? _imageBytes;
  bool _uploadingMedia = false;

  Future<void> _pickMedia(ImageSource source) async {
    setState(() => _uploadingMedia = true);
    final picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      final raw = await pickedFile.readAsBytes();
      final compressed = await ImageUtils.compressForFirestore(raw);

      if (!mounted) return;
      setState(() => _imageBytes = compressed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar imagen: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingMedia = false);
    }
  }

  bool get _canConfirm => _selectedPlayer != null && _imageBytes != null;

  void _confirm() {
    if (!_canConfirm) return;

    // Devolvemos datos y cerramos pantalla
    Navigator.pop(context, {
      'player': _selectedPlayer,
      'image': _imageBytes,
    });
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final color = AfterlifeColors.electricLilac;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Completar reto',
          style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta del reto
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AfterlifeColors.electricLilac, AfterlifeColors.neonPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['name'] ?? 'Reto',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${challenge['points'] ?? 0} pts',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Texto selector de jugador
          Text(
            '¿QUIÉN COMPLETA EL RETO?',
            style: TextStyle(
              color: AfterlifeColors.electricLilac,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Selector de jugador con estilo original
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedPlayer,
              hint: Text('Selecciona un jugador', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: const Icon(Icons.arrow_drop_down, color: AfterlifeColors.electricLilac),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: const InputDecoration(border: InputBorder.none),
              items: widget.players.map<DropdownMenuItem<String>>((player) {
                return DropdownMenuItem<String>(
                  value: player['name'] as String,
                  child: Row(
                    children: [
                      AfterlifeAvatar(
                        initials: player['initials'] ?? '?',
                        status: AvatarStatus.online,
                        size: 24,
                        showStatusIndicator: false,
                      ),
                      const SizedBox(width: 8),
                      Text(player['name'] ?? ''),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPlayer = value),
            ),
          ),

          const SizedBox(height: 24),

          // Texto de prueba multimedia
          Text(
            'PRUEBA (OBLIGATORIA)',
            style: TextStyle(
              color: AfterlifeColors.cyanBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Sección de imagen con estilo original
          if (_imageBytes != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AfterlifeColors.acidGreen, width: 2),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).disabledColor,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'Error al cargar la imagen',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 18),
                      ),
                      onPressed: () => setState(() => _imageBytes = null),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _uploadingMedia ? null : () => _pickMedia(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AfterlifeColors.cyanBlue,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _uploadingMedia ? null : () => _pickMedia(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AfterlifeColors.neonPink,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_uploadingMedia)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),

          const SizedBox(height: 32),

          // Botón confirmar
          AfterButton(
            label: 'CONFIRMAR',
            color: _canConfirm ? AfterlifeColors.acidGreen : Theme.of(context).disabledColor,
            onPressed: _canConfirm ? _confirm : null,
          ),
        ],
      ),
    );
  }
}
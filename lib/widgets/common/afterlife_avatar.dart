// Widget reutilizable para mostrar el avatar de cualquier usuario.
// Sistema de prioridad para la imagen: bytes (Firestore) > URL (red/local) > iniciales.
// También puede mostrar un indicador de estado en la esquina inferior derecha.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class AfterlifeAvatar extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes; // Bytes guardados en Firestore; tienen prioridad sobre imageUrl
  final String? initials;
  final double size;
  final AvatarStatus status;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showStatusIndicator;

  const AfterlifeAvatar({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.initials,
    this.size = 48,
    this.status = AvatarStatus.online,
    this.backgroundColor,
    this.borderColor,
    this.showStatusIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatarBackground = backgroundColor ?? AfterlifeColors.electricPurple;
    final avatarBorder = borderColor ?? AfterlifeColors.electricPurple;

    // El Container usa BoxDecoration.image para pintar la foto encima del color de fondo.
    // Si no hay imagen (_buildImage() devuelve null), muestra las iniciales como Text.
    // Nota: _buildImage() se llama dos veces (decoration + child), pero es barato.
    final avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarBackground,
        borderRadius: BorderRadius.circular(size / 2), // siempre círculo perfecto
        border: Border.all(color: avatarBorder, width: 2),
        image: _buildImage(),
      ),
      child: _buildImage() == null && initials != null && initials!.isNotEmpty
          ? Center(
              child: Text(
                _getInitials(initials!),
                style: TextStyle(
                  color: AfterlifeColors.electricPurple,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );

    if (!showStatusIndicator) {
      return avatarContent;
    }

    // El Stack con Clip.none permite que el punto de estado sobresalga del círculo
    // sin que sea recortado por el tamaño del widget padre
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: _getStatusColor(context, status),
              borderRadius: BorderRadius.circular(size * 0.15),
              // Borde del color del fondo de pantalla para simular separación entre círculos
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Devuelve la imagen con la prioridad correcta:
  // 1. imageBytes: foto guardada en Firestore como Uint8List → MemoryImage (no necesita red)
  // 2. imageUrl: URL de red o ruta local → NetworkImage / FileImage
  // 3. null: el widget muestra iniciales en su lugar
  DecorationImage? _buildImage() {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return DecorationImage(image: _resolveUrl(imageUrl!), fit: BoxFit.cover);
    }
    return null;
  }

  // Las rutas locales comienzan con '/' (solo en móvil, no en web).
  // En web todas las imágenes son URLs de red.
  ImageProvider _resolveUrl(String url) {
    if (!kIsWeb && url.startsWith('/')) {
      return FileImage(File(url));
    }
    return NetworkImage(url);
  }

  // Extrae iniciales: "Unai Franes" → "UF", "Unai" → "U"
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  Color _getStatusColor(BuildContext context, AvatarStatus status) {
    switch (status) {
      case AvatarStatus.inNight:
        return AfterlifeColors.electricPurple;
      case AvatarStatus.online:
        return AfterlifeColors.acidGreen;
      case AvatarStatus.offline:
        return Theme.of(context).disabledColor;
    }
  }
}

enum AvatarStatus {
  inNight, // En una noche activa
  online,  // Conectado
  offline, // Sin conexión / inactivo
}

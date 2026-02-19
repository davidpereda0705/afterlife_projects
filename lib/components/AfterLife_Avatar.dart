// lib/core/widgets/afterlife_avatar.dart
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class AfterlifeAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final AvatarStatus status;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showStatusIndicator;

  const AfterlifeAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.status = AvatarStatus.online,
    this.backgroundColor,
    this.borderColor,
    this.showStatusIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    // Color de fondo con opacidad
    final avatarBackground = backgroundColor ?? AfterlifeColors.electricPurple;
    final avatarBorder = borderColor ?? AfterlifeColors.electricPurple;

    final avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarBackground,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: avatarBorder,
          width: 2,
        ),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null && initials != null
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

    // Si no muestra indicador de estado, retornar solo el avatar
    if (!showStatusIndicator) {
      return avatarContent;
    }

    // Avatar con indicador de estado
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        
        // Indicador de estado (esquina inferior derecha)
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(size * 0.15),
              border: Border.all(
                color: AfterlifeColors.background,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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

  /// Obtiene las iniciales del nombre
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  /// Retorna el color correspondiente al estado
  Color _getStatusColor(AvatarStatus status) {
    switch (status) {
      case AvatarStatus.inNight:
        return AfterlifeColors.electricPurple;
      case AvatarStatus.online:
        return AfterlifeColors.acidGreen;
      case AvatarStatus.offline:
        return AfterlifeColors.textDisabled;
    }
  }
}

/// Estados del avatar para Afterlife
enum AvatarStatus {
  inNight,  // 🔴 En una noche activa
  online,   // 🟢 Online
  offline,  // ⚫ Offline
}
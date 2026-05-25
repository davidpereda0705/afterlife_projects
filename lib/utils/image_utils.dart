// Utilidades de compresión de imágenes: reduce fotos a menos de 120KB para guardarlas en Firestore.
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  // Presupuesto por imagen: 120KB
  // Con 3 fotos de noche + 5 pruebas de retos = máx 960KB → cabe en 1MB de Firestore
  static const int _targetBytes = 120 * 1024;

  /// Comprime [source] hasta que mida menos de 120KB.
  /// Primer intento: JPEG 600×600 calidad 50.
  /// Segundo intento: JPEG 400×400 calidad 35.
  /// Lanza [Exception] si no se puede comprimir suficiente.
  static Future<Uint8List> compressForFirestore(Uint8List source) async {
    var result = await FlutterImageCompress.compressWithList(
      source,
      minWidth: 600,
      minHeight: 600,
      quality: 50,
      format: CompressFormat.jpeg,
    );

    if (result.length > _targetBytes) {
      result = await FlutterImageCompress.compressWithList(
        source,
        minWidth: 400,
        minHeight: 400,
        quality: 35,
        format: CompressFormat.jpeg,
      );
    }

    if (result.length > _targetBytes) {
      final kb = (result.length / 1024).toStringAsFixed(0);
      throw Exception(
        'La imagen sigue siendo demasiado grande (${kb}KB tras comprimir). '
        'Elige otra foto con menos detalle.',
      );
    }

    return result;
  }
}

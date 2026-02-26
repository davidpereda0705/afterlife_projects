import 'package:afterlife_projects/components/splash_loading.dart';
import 'package:afterlife_projects/theme/AfterlifeTheme.dart';
import 'package:flutter/material.dart';
import 'theme/colors.dart';

void main() => runApp(const AfterlifeApp());

class AfterlifeApp extends StatelessWidget {
  const AfterlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afterlife',
      // Usamos el tema oscuro neón de tu archivo de colores
      theme: AfterlifeTheme.darkTheme, 
      // El punto de inicio de la app es la animación de carga
      home: const SplashLoading(), 
    );
  }
}
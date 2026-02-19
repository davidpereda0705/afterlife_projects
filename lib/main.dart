import 'package:afterlife_projects/components/splash_loading.dart';
import 'package:flutter/material.dart';
import 'components/AfterButton.dart';
import 'theme/colors.dart';
import 'theme/AfterlifeTheme.dart';

void main() {
  runApp(const AfterlifeApp());
}

class AfterlifeApp extends StatelessWidget {
  const AfterlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afterlife',
      theme: AfterlifeTheme.darkTheme, // Usa el tema de tu archivo de colores
      home: const SplashLoading(), // Arranca con la carga automática tipo Instagram
    );
  }
}
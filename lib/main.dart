import 'package:afterlife_projects/components/welcome_screen.dart';
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
      theme: AfterlifeTheme.darkTheme, // Cargado desde colors.dart
      home: const WelcomeScreen(), // Empezamos por la pantalla de "Clica para entrar"
    );
  }
}
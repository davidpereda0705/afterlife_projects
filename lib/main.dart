// lib/main.dart
import 'package:afterlife_projects/Home.dart';
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
      theme: AfterlifeTheme.darkTheme,
      home: const WelcomePage(), // Primera pantalla: Bienvenida
    );
  }
}

// Pantalla de bienvenida (con el botón)
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o título
            Text(
              'AFTERLIFE',
              style: TextStyle(
                color: AfterlifeColors.electricPurple,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Tu botón
            AfterButton(
              label: 'ENTRAR',
              size: 120,
              color: AfterlifeColors.electricPurple,
              onPressed: () {
                // Navegar a HomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
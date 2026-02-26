import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos tu nuevo fondo negro profundo como base
      backgroundColor: AfterlifeColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Aplicamos el nuevo gradiente eléctrico oficial
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // Resplandor usando tu nuevo Púrpura Eléctrico con opacidad
                    color: AfterlifeColors.electricPurple.withOpacity(0.5),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/imatges/logo_afterlife.png', // Tu ruta confirmada
                width: 380, // Tamaño monumental mantenido
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
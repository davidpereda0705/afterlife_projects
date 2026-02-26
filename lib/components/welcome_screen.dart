import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'login_page.dart'; // <--- Importamos la nueva pantalla de Login

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mismo fondo de degradado lila/rosa de fiesta para mantener la coherencia
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0B2E), // Morado oscuro
              Color(0xFF4A148C), // Lila fiesta
              Color(0xFF880E4F), // Rosa neón
            ],
          ),
        ),
        child: Center(
          child: GestureDetector(
            // Al pulsar el logo gigante, ahora vamos al Login/Registro
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE040FB).withOpacity(0.5), // Resplandor lila
                    blurRadius: 100, // Brillo muy expansivo
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/imatges/logo_afterlife.png', // Tu ruta confirmada
                width: 380, // Tamaño monumental igualado
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
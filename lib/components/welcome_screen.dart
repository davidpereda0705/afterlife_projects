import 'package:afterlife_projects/components/splash_loading.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0B2E), Color(0xFF4A148C), Color(0xFF880E4F)],
          ),
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SplashLoading()),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE040FB).withOpacity(0.6),
                    blurRadius: 100, // Brillo neón masivo
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/imatges/logo_afterlife.png',
                width: 380, // MISMO TAMAÑO GIGANTE
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
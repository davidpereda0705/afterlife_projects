import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/screens/auth/welcome_screen.dart';

class SplashLoading extends StatefulWidget {
  const SplashLoading({super.key});

  @override
  State<SplashLoading> createState() => _SplashLoadingState();
}

class _SplashLoadingState extends State<SplashLoading> {
  @override
  void initState() {
    super.initState();
    // Espera 3 segundos y salta a la siguiente
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Aplicamos tu nuevo gradiente de lila eléctrico + palmeras
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
          image: const DecorationImage(
            image: AssetImage('assets/imatges/palmeras.png'),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter, // 🌴 abajo
            opacity: 0.25, // 🔥 ajustable
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO GIGANTE (380px)
            Image.asset(
              'assets/imatges/logo_afterlife.png',
              width: 380,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 50),
            // LA ANIMACIÓN DE CARGA con tu nuevo Lila Eléctrico
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AfterlifeColors.electricLilac),
              strokeWidth: 6,
            ),
          ],
        ),
      ),
    );
  }
}

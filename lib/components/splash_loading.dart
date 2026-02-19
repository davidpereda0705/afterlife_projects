import 'package:afterlife_projects/main.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SplashLoading extends StatefulWidget {
  const SplashLoading({super.key});

  @override
  State<SplashLoading> createState() => _SplashLoadingState();
}

class _SplashLoadingState extends State<SplashLoading> {
  @override
  void initState() {
    super.initState();
    // Espera 3 segundos (identidad de marca) y salta sola
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AfterlifeApp()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background, // Tu fondo negro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu logo centrado
            Image.asset('assets/imatges/logo.png', width: 150), 
            const SizedBox(height: 30),
            // Un pequeño indicador neón para que sepa que está cargando
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AfterlifeColors.electricLilac),
            ),
          ],
        ),
      ),
    );
  }
}
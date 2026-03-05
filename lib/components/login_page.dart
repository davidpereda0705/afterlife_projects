import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/main.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/imatges/logo_afterlife.png',
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                isLogin ? 'BIENVENIDO' : 'ÚNETE A LA FIESTA',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AfterlifeColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              _buildTextField(Icons.person_outline, 'USUARIO'),
              const SizedBox(height: 20),

              _buildTextField(
                Icons.lock_outline,
                'CONTRASEÑA',
                isPassword: true,
              ),

              if (!isLogin) ...[
                const SizedBox(height: 20),
                _buildTextField(
                  Icons.lock_reset_outlined,
                  'REPETIR CONTRASEÑA',
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(Icons.email_outlined, 'EMAIL'),
              ],

              const SizedBox(height: 50),

              AfterButton(
                label: isLogin ? 'ENTRAR' : 'REGISTRAR',
                size: 130,
                color: AfterlifeColors.electricLilac,
                onPressed: () {
                  // 👇 Navegar al HomeScreen y eliminar Login de la pila
                  // Al final del onPressed del botón AfterButton, cambiar:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ), // antes era HomeScreen
                  );
                },
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? '¿No tienes cuenta? REGÍSTRATE'
                      : '¿Ya tienes cuenta? ENTRA',
                  style: TextStyle(
                    color: AfterlifeColors.textSecondary,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: AfterlifeColors.textPrimary, fontFamily: 'Syne'),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AfterlifeColors.electricPurple),
        hintText: hint,
        hintStyle: TextStyle(color: AfterlifeColors.textDisabled, fontSize: 12),
        filled: true,
        fillColor: AfterlifeColors.surfaceDark.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: AfterlifeColors.electricPurple.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AfterlifeColors.electricPurple,
            width: 2,
          ),
        ),
      ),
    );
  }
}

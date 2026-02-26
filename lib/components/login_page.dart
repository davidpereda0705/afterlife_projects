import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // Controla si mostramos Login o Registro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fondo degradado de fiesta Afterlife
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // LOGO GIGANTE (250px para que quepan los inputs)
              Image.asset(
                'assets/imatges/logo_afterlife.png',
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                isLogin ? 'BIENVENIDO' : 'ÚNETE A LA FIESTA',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              
              // Campo de Usuario siempre visible
              _buildTextField(Icons.person_outline, 'USUARIO'),
              const SizedBox(height: 20),
              
              // Primer campo de Contraseña
              _buildTextField(Icons.lock_outline, 'CONTRASEÑA', isPassword: true),
              
              // NUEVO: Campo de Confirmación (Solo sale en Registro)
              if (!isLogin) ...[
                const SizedBox(height: 20),
                _buildTextField(Icons.lock_reset_outlined, 'REPETIR CONTRASEÑA', isPassword: true),
                const SizedBox(height: 20),
                _buildTextField(Icons.email_outlined, 'EMAIL'),
              ],
              
              const SizedBox(height: 50),
              
              // Botón de acción principal Afterlife
              AfterButton(
                label: isLogin ? 'ENTRAR' : 'REGISTRAR',
                size: 130,
                color: AfterlifeColors.electricLilac,
                onPressed: () {
                  print(isLogin ? "Logueando..." : "Registrando...");
                },
              ),
              
              const SizedBox(height: 30),
              
              // Botón para cambiar entre Login y Registro
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin ? '¿No tienes cuenta? REGÍSTRATE' : '¿Ya tienes cuenta? ENTRA',
                  style: const TextStyle(
                    color: Colors.white70,
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

  // Estilo de los campos de texto con borde lila neón
  Widget _buildTextField(IconData icon, String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontFamily: 'Syne'),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFE040FB)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE040FB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE040FB), width: 2),
        ),
      ),
    );
  }
}
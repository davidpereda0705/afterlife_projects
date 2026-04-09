// lib/screens/login_page.dart
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/main_screen.dart';
import 'package:afterlife_projects/services/auth_services.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para capturar excepciones específicas


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool isLoading = false; // 👈 Estado de carga

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Para registro (email)
  final TextEditingController _userController = TextEditingController();   // En login será email, en registro será nombre de usuario

  final AuthService _auth = AuthService();

  void _intentarAcceder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los datos marcados en rojo'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // Login: el campo "USUARIO" debe ser un email
        final email = _userController.text.trim();
        final password = _passController.text.trim();
        await _auth.signInWithEmail(email, password);
        // El StreamBuilder en main.dart redirigirá automáticamente a MainScreen
      } else {
        // Registro: necesitamos email, contraseña y nombre de usuario
        final email = _emailController.text.trim();
        final password = _passController.text.trim();
        final username = _userController.text.trim();
        await _auth.registerWithEmail(email, password, username); // Ajustamos el método para guardar nombre
        // También se redirige automáticamente
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta';
          break;
        case 'email-already-in-use':
          mensaje = 'El email ya está registrado';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es demasiado débil';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

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
          child: Form(
            key: _formKey,
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

                // CAMPO PRINCIPAL (Email en login, Nombre de usuario en registro)
                _buildTextField(
                  Icons.person_outline,
                  isLogin ? 'EMAIL' : 'NOMBRE DE USUARIO',
                  controller: _userController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obligatorio';
                    if (isLogin) {
                      if (!value.contains('@')) return 'Introduce un email válido';
                    } else {
                      if (value.length < 3) return 'Mínimo 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // CONTRASEÑA
                _buildTextField(
                  Icons.lock_outline,
                  'CONTRASEÑA',
                  isPassword: true,
                  controller: _passController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Contraseña obligatoria';
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#\$&*~]).*$').hasMatch(value)) {
                      return 'Añade un número y un símbolo (!@#)';
                    }
                    return null;
                  },
                ),

                if (!isLogin) ...[
                  const SizedBox(height: 20),
                  // REPETIR CONTRASEÑA
                  _buildTextField(
                    Icons.lock_reset_outlined,
                    'REPETIR CONTRASEÑA',
                    isPassword: true,
                    controller: _confirmPassController,
                    validator: (value) {
                      if (value != _passController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // EMAIL (solo en registro)
                  _buildTextField(
                    Icons.email_outlined,
                    'EMAIL',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Introduce un email válido';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 50),

                if (isLoading)
                  const CircularProgressIndicator()
                else
                  AfterButton(
                    label: isLogin ? 'ENTRAR' : 'REGISTRAR',
                    color: AfterlifeColors.electricLilac,
                    onPressed: _intentarAcceder,
                  ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                    // Limpiamos controladores para evitar validaciones cruzadas
                    _passController.clear();
                    _confirmPassController.clear();
                    _emailController.clear();
                    _userController.clear();
                    setState(() => isLogin = !isLogin);
                  },
                  child: Text(
                    isLogin ? '¿No tienes cuenta? REGÍSTRATE' : '¿Ya tienes cuenta? ENTRA',
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
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: TextStyle(color: AfterlifeColors.textPrimary, fontFamily: 'Syne'),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AfterlifeColors.electricPurple),
        hintText: hint,
        hintStyle: TextStyle(color: AfterlifeColors.textDisabled, fontSize: 12),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/main.dart'; // Cambiado a MainScreen según tu código
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;

  // 1. LLAVE PARA EL FORMULARIO (Imprescindible para las restricciones)
  final _formKey = GlobalKey<FormState>();

  // 2. CONTROLADORES (Para leer los textos y comparar contraseñas)
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

  // 3. FUNCIÓN QUE EJECUTA LAS RESTRICCIONES
  void _intentarAcceder() {
    if (_formKey.currentState!.validate()) {
      // Si pasa todas las reglas, entramos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Si falla algo, mostramos un aviso rápido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los datos marcados en rojo'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
            key: _formKey, // Envolvemos todo en el Form
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

                // USUARIO
                _buildTextField(
                  Icons.person_outline,
                  'USUARIO',
                  controller: _userController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Escribe un nombre';
                    if (value.length < 3) return 'Demasiado corto';
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
                    // Regla: Debe tener al menos un número y un símbolo
                    if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#\$&*~]).*$').hasMatch(value)) {
                      return 'Añade un número y un símbolo (!@#)';
                    }
                    return null;
                  },
                ),

                if (!isLogin) ...[
                  const SizedBox(height: 20),
                  // REPETIR CONTRASEÑA (Restricción de igualdad)
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
                  // EMAIL
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

                AfterButton(
                  label: isLogin ? 'ENTRAR' : 'REGISTRAR',
                  size: 130,
                  color: AfterlifeColors.electricLilac,
                  onPressed: _intentarAcceder, // Ejecuta la validación
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    _formKey.currentState?.reset(); // Limpia errores al cambiar modo
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

  // WIDGET PERSONALIZADO USANDO TEXTFORMFIELD (Para que funcionen los errores)
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
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11), // Color del error
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
        // Bordes cuando hay un error
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
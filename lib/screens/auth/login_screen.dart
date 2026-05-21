import 'dart:ui';
import 'package:afterlife_projects/widgets/common/after_button.dart';
import 'package:afterlife_projects/services/auth_services.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

  final AuthService _auth = AuthService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _emailController.dispose();
    _userController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  Future<void> _markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  void _intentarAcceder() async {
    // Si no es login, validamos el formulario normalmente
    if (!isLogin && !(_formKey.currentState?.validate() ?? false)) return;
    
    // Si es login, solo comprobamos que no estén vacíos
    if (isLogin && (_userController.text.trim().isEmpty || _passController.text.trim().isEmpty)) {
      _showError('Introduce tus datos');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        final user = await _auth.signInWithEmail(_userController.text.trim(), _passController.text.trim());
        if (user != null) {
          await user.reload();
          final freshUser = FirebaseAuth.instance.currentUser;
          if (freshUser != null && !freshUser.emailVerified && mounted) {
            await _auth.signOut();
            _showError('Verifica tu email antes de iniciar sesión. Revisa tu bandeja de entrada.');
            await _auth.sendVerificationEmail();
            setState(() => isLoading = false);
            return;
          }
        }
      } else {
        await _auth.registerWithEmail(
          _emailController.text.trim(),
          _passController.text.trim(),
          _userController.text.trim(),
        );
      }
      await _markOnboardingAsSeen();
    } on FirebaseAuthException catch (e) {
      if (isLogin) {
        _showError('Nombre / contraseña incorrecto, inténtalo de nuevo');
      } else {
        _showError(e.message ?? 'Error al registrarse');
      }
    } catch (e) {
      _showError('Nombre / contraseña incorrecto, inténtalo de nuevo');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo Dinámico
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    AfterlifeColors.electricPurple.withValues(alpha: 0.15),
                    Theme.of(context).scaffoldBackgroundColor,
                    AfterlifeColors.electricLilac.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          
          // Elementos Decorativos (Círculos difusos)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AfterlifeColors.electricLilac.withValues(alpha: 0.2),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container()),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo y Título
                      Image.asset(
                        'assets/imatges/logo_afterlife.png',
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),

                      // Contenedor Glassmorphism
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    icon: Icons.person_outline,
                                    label: isLogin ? 'EMAIL' : 'USUARIO',
                                    controller: _userController,
                                    validator: isLogin ? null : (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                                  ),
                                  
                                  if (!isLogin) ...[
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      icon: Icons.alternate_email,
                                      label: 'EMAIL',
                                      controller: _emailController,
                                      validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                                    ),
                                  ],

                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    icon: Icons.lock_outline,
                                    label: 'CONTRASEÑA',
                                    isPassword: true,
                                    showPassword: showPassword,
                                    togglePassword: () => setState(() => showPassword = !showPassword),
                                    controller: _passController,
                                    validator: isLogin ? null : (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                                  ),

                                  if (!isLogin) ...[
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      icon: Icons.security_outlined,
                                      label: 'REPETIR CONTRASEÑA',
                                      isPassword: true,
                                      showPassword: showPassword,
                                      controller: _confirmPassController,
                                      validator: (v) => v != _passController.text ? 'No coinciden' : null,
                                    ),
                                  ],

                                  const SizedBox(height: 32),
                                  
                                  isLoading
                                      ? const CircularProgressIndicator(color: AfterlifeColors.electricPurple)
                                      : AfterButton(
                                          label: isLogin ? 'INICIAR SESIÓN' : 'REGISTRARSE',
                                          color: AfterlifeColors.electricLilac,
                                          onPressed: _intentarAcceder,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      
                      // Footer
                      TextButton(
                        onPressed: _switchMode,
                        child: RichText(
                          text: TextSpan(
                            text: isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                            children: [
                              TextSpan(
                                text: isLogin ? 'REGÍSTRATE' : 'ENTRA',
                                style: const TextStyle(
                                  color: AfterlifeColors.electricPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    bool isPassword = false,
    bool? showPassword,
    VoidCallback? togglePassword,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(showPassword ?? false),
      validator: validator,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
        prefixIcon: Icon(icon, color: AfterlifeColors.electricPurple.withValues(alpha: 0.7), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (showPassword ?? false) ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                  size: 20,
                ),
                onPressed: togglePassword,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfterlifeColors.electricPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}

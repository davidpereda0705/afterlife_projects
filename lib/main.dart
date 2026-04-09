// lib/main.dart
import 'package:afterlife_projects/components/login_page.dart';
import 'package:afterlife_projects/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/AfterlifeTheme.dart';
import 'firebase_options.dart'; // 👈 Importante: archivo generado por flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase con las opciones específicas de la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Mensaje de verificación en consola
  print('✅ Firebase inicializado correctamente en ${defaultTargetPlatform}');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afterlife',
      theme: AfterlifeTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            print('✅ Usuario autenticado: ${snapshot.data!.email}');
            return const MainScreen();
          }
          print('❌ Usuario no autenticado, mostrando login');
          return const LoginPage();
        },
      ),
    );
  }
}
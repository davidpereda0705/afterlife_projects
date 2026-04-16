import 'package:afterlife_projects/components/login_page.dart';
import 'package:afterlife_projects/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/AfterlifeTheme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/services/achievement_service.dart'; // 👈 Importar el servicio
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar logros por defecto (solo la primera vez)
  final achievementService = AchievementService();
  await achievementService.initializeDefaultAchievements();

  print('✅ Firebase inicializado correctamente en ${defaultTargetPlatform}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
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
              // El UserProvider ya está en el árbol, no es necesario leerlo aquí
              return const MainScreen();
            }
            print('❌ Usuario no autenticado, mostrando login');
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
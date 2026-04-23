import 'package:afterlife_projects/components/login_page.dart';
import 'package:afterlife_projects/main_screen.dart';
import 'package:afterlife_projects/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/AfterlifeTheme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar logros por defecto (solo la primera vez)
  final achievementService = AchievementService();
  await achievementService.initializeDefaultAchievements();

  debugPrint('✅ Firebase inicializado correctamente en ${defaultTargetPlatform}');

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
        home: const OnboardingWrapper(),
      ),
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    setState(() {
      _showOnboarding = !hasSeenOnboarding;
      _isLoading = false;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingScreen(onDone: _completeOnboarding);
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}
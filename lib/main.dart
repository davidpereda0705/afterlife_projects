import 'package:afterlife_projects/components/login_page.dart';
import 'package:afterlife_projects/main_screen.dart';
import 'package:afterlife_projects/night_game_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/AfterlifeTheme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/providers/settings_provider.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:afterlife_projects/services/biometric_service.dart';
import 'package:afterlife_projects/edit_profile.dart';
import 'package:afterlife_projects/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/backgrounds/disco_background.dart';
import 'screens/tutorial_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final achievementService = AchievementService();
  await achievementService.initializeDefaultAchievements();
  debugPrint('✅ Firebase inicializado correctamente en $defaultTargetPlatform');
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Afterlife',
            theme: AfterlifeTheme.lightTheme,
            darkTheme: AfterlifeTheme.darkTheme,
            themeMode: settings.themeMode,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontSizeFactor),
                ),
                child: settings.backgroundEffects
                    ? DiscoBackground(child: child!)
                    : child!,
              );
            },
            home: const OnboardingWrapper(),
            routes: {
              '/edit-profile': (context) => const EditProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
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
  bool _hasSeenTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
    _handleDeepLink();
  }

  void _handleDeepLink() {
    if (kIsWeb) {
      final uri = Uri.base;
      final nightId = uri.queryParameters['nightId'];
      if (nightId != null && nightId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NightGameScreen(nightId: nightId),
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_tutorial') ?? false;
    if (mounted) {
      setState(() {
        _hasSeenTutorial = seen;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);
    if (mounted) setState(() => _hasSeenTutorial = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user != null) {
          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading && userProvider.userData == null) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              // Tutorial interactivo la primera vez que entras
              if (!_hasSeenTutorial) {
                return TutorialScreen(onDone: _completeTutorial);
              }
              return const BiometricGate(child: MainScreen());
            },
          );
        }

        // Sin sesión → directo al login
        return const LoginPage();
      },
    );
  }
}

/// Pantalla intermedia que pide biometría al volver de segundo plano.
/// En web se ignora automáticamente.
class BiometricGate extends StatefulWidget {
  final Widget child;
  const BiometricGate({super.key, required this.child});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _supportsBio = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addObserver(this);
      _checkSupport();
    }
  }

  Future<void> _checkSupport() async {
    final can = await BiometricService.canCheckBiometrics();
    setState(() => _supportsBio = can);
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb || !_supportsBio) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      setState(() => _locked = true);
    }
    if (state == AppLifecycleState.resumed && _locked) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    final ok = await BiometricService.authenticate();
    if (ok && mounted) {
      setState(() => _locked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_supportsBio || !_locked) return widget.child;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Afterlife bloqueado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text('DESBLOQUEAR'),
            ),
          ],
        ),
      ),
    );
  }
}
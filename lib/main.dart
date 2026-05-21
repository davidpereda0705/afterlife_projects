import 'package:afterlife_projects/widgets/effects/disco_background.dart';
import 'package:afterlife_projects/screens/auth/login_screen.dart';
import 'package:afterlife_projects/screens/main/main_screen.dart';
import 'package:afterlife_projects/screens/nights/night_game_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/afterlife_theme.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/providers/settings_provider.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:afterlife_projects/screens/settings/edit_profile_screen.dart';
import 'package:afterlife_projects/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afterlife_projects/screens/settings/tutorial_screen.dart';
import 'package:afterlife_projects/firebase_options.dart';

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
  String? _lastCheckedUid;

  @override
  void initState() {
    super.initState();
    _handleDeepLink();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _lastCheckedUid = user.uid;
      await _checkTutorial(user.uid);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Future<void> _checkTutorial(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_tutorial_$uid') ?? false;
    if (mounted) {
      setState(() {
        _hasSeenTutorial = seen;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeTutorial() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial_$uid', true);
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
          // Si el usuario cambió (nuevo registro o login), re-verificar tutorial
          if (_lastCheckedUid != user.uid) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _lastCheckedUid != user.uid) {
                _lastCheckedUid = user.uid;
                _checkTutorial(user.uid);
              }
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading && userProvider.userData == null) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (!_hasSeenTutorial) {
                return TutorialScreen(onDone: _completeTutorial);
              }
              return const MainScreen();
            },
          );
        }

        // Sin sesión → directo al login
        return const LoginPage();
      },
    );
  }
}


// lib/screens/main_screen.dart
import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/logros.dart';
import 'package:afterlife_projects/minigames_screen.dart';
import 'package:afterlife_projects/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/components/BottomNav.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart'; // Asegúrate de importar esto
import 'package:afterlife_projects/components/splash_loading.dart';
import 'package:afterlife_projects/ActiveNightManager.dart';
import 'package:afterlife_projects/night_game_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.group_outlined, selectedIcon: Icons.group, label: 'Amigos'),
    BottomNavItem(icon: Icons.nightlight_outlined, selectedIcon: Icons.nightlight_round, label: 'Noches'),
    BottomNavItem(icon: Icons.sports_esports_outlined, selectedIcon: Icons.sports_esports, label: 'Minijuegos'),
    BottomNavItem(icon: Icons.emoji_events_outlined, selectedIcon: Icons.emoji_events, label: 'Logros'),
    BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Perfil'),
  ];

  late final List<Widget> _pages = [
    const HomeScreen(),
    const GroupPage(),
    const NightSelectionScreen(),
    const MinigamesScreen(),
    const AchievementsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Row(
          children: [
            // Indicador de noche activa
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: ActiveNightManager().activeNight,
              builder: (context, activeNight, child) {
                if (activeNight == null) return const SizedBox();
                return GestureDetector(
                  onTap: () {
                    // Navegar a la noche activa
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NightGameScreen(nightData: activeNight),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AfterlifeColors.acidGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AfterlifeColors.acidGreen),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.nightlight_round, size: 16, color: Color(0xFF84CC16)),
                        const SizedBox(width: 6),
                        const Text(
                          'Noche activa',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Text(
              'Afterlife',
              style: AfterlifeTextTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Puedes añadir acciones si lo deseas
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: AfterlifeBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _navItems,
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afterlife Projects',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashLoading(),
    );
  }
}
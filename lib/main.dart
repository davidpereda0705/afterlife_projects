import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/logros.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/components/BottomNav.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/components/splash_loading.dart';

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
    BottomNavItem(icon: Icons.emoji_events_outlined, selectedIcon: Icons.emoji_events, label: 'Logros'),
    BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Perfil'),
  ];

  late final List<Widget> _pages = [
    const HomeScreen(),
    const GroupPage(),
    const NightSelectionScreen(),
    const AchievementsScreen(),
    // Placeholder para Perfil (puedes reemplazar con tu pantalla de perfil más adelante)
    Container(
      color: AfterlifeColors.background,
      child: const Center(
        child: Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
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
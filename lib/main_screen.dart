import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/minigames_screen.dart';
import 'package:afterlife_projects/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:afterlife_projects/components/BottomNav.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
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
    BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Perfil'),
  ];

  late final List<Widget> _pages = [
    HomeScreen(),
    const GroupPage(),
    const NightSelectionScreen(),
    const MinigamesScreen(),
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
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final activeNightId = userProvider.activeNightId;
            if (activeNightId != null) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NightGameScreen(nightId: activeNightId),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.acidGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AfterlifeColors.acidGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.nightlight_round, size: 20, color: AfterlifeColors.acidGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Noche activa',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Text(
                'Afterlife',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
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
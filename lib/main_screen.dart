import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/clubs_screen.dart';
import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/profile_screen.dart';
import 'package:afterlife_projects/ranking_screen.dart';
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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Inicio'),
    BottomNavItem(icon: Icons.group_outlined, selectedIcon: Icons.group, label: 'Amigos'),
    BottomNavItem(icon: Icons.nightlight_outlined, selectedIcon: Icons.nightlight_round, label: 'Noches'),
    BottomNavItem(icon: Icons.leaderboard_outlined, selectedIcon: Icons.leaderboard, label: 'Ranking'),
    BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Perfil'),
  ];

  late final List<Widget> _pages = [
    HomeScreen(onNavigateToNights: () => _onItemTapped(2)),
    const GroupPage(),
    const NightSelectionScreen(),
    const RankingScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D0D1A), Color(0xFF060610)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF8F5FF)],
                  ),
          ),
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.acidGreen.withValues(alpha: isDark ? 0.12 : 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AfterlifeColors.acidGreen.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AfterlifeColors.acidGreen.withValues(alpha: isDark ? 0.2 : 0.15),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AfterlifeColors.acidGreen.withValues(
                                alpha: _pulseAnimation.value,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AfterlifeColors.acidGreen.withValues(
                                    alpha: _pulseAnimation.value * 0.6,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NOCHE ACTIVA',
                        style: TextStyle(
                          color: AfterlifeColors.acidGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AfterlifeColors.acidGreen.withValues(alpha: 0.7),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFA855F7),
                    Color(0xFFEC4899),
                    Color(0xFF06B6D4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'AFTERLIFE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 3,
                  ),
                ),
              );
            }
          },
        ),
        actions: [
          const SizedBox(width: 4),
        ],
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

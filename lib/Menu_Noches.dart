// lib/screens/night_selection_screen.dart
import 'package:afterlife_projects/Home.dart';
import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/create_night_screen.dart' hide BottomNavItem;
import 'package:afterlife_projects/join_night_screen.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/AfterlifeTheme.dart';
import '../components/AfterLifeCard.dart';
import '../components/BottomNav.dart';

class NightSelectionScreen extends StatefulWidget {
  const NightSelectionScreen({super.key});

  @override
  State<NightSelectionScreen> createState() => _NightSelectionScreenState();
}

class _NightSelectionScreenState extends State<NightSelectionScreen> {
  int _selectedIndex = 2;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.group_outlined, selectedIcon: Icons.group, label: 'Amigos'),
    BottomNavItem(icon: Icons.nightlight_outlined, selectedIcon: Icons.nightlight_round, label: 'Noches'),
    BottomNavItem(icon: Icons.emoji_events_outlined, selectedIcon: Icons.emoji_events, label: 'Logros'),
    BottomNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Noches',
          style: TextStyle(
            color: AfterlifeColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿QUÉ QUIERES HACER?',
              style: TextStyle(
                color: AfterlifeColors.electricPurple,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            
            AfterlifeCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateNightScreen()),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AfterlifeColors.electricLilac.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_circle_outline, color: AfterlifeColors.electricLilac, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CREAR NOCHE', style: TextStyle(color: AfterlifeColors.electricLilac, fontSize: 18)),
                        Text('Organiza una nueva noche', style: TextStyle(color: AfterlifeColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AfterlifeColors.electricLilac, size: 16),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            AfterlifeCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinNightScreen()),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AfterlifeColors.neonPink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.group_add_outlined, color: AfterlifeColors.neonPink, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UNIRSE A NOCHE', style: TextStyle(color: AfterlifeColors.neonPink, fontSize: 18)),
                        Text('Únete a una noche en espera', style: TextStyle(color: AfterlifeColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AfterlifeColors.neonPink, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AfterlifeBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupPage()),
              );
              break;
            case 2:
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pantalla de Logros - Próximamente')),
              );
              break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pantalla de Perfil - Próximamente')),
              );
              break;
          }
        },
        items: _navItems,
      ),
    );
  }
}
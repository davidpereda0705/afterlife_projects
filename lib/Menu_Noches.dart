// lib/screens/night_selection_screen.dart
import 'package:afterlife_projects/create_night_screen.dart';
import 'package:afterlife_projects/join_night_screen.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../components/AfterLifeCard.dart';

class NightSelectionScreen extends StatelessWidget {
  const NightSelectionScreen({super.key});

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
            
            // Opción CREAR NOCHE
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
            
            // Opción UNIRSE A NOCHE
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
    );
  }
}
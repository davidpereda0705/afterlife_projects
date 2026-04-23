import 'package:afterlife_projects/create_night_screen.dart';
import 'package:afterlife_projects/join_night_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../components/AfterLifeCard.dart';
import '../providers/user_provider.dart';

class NightSelectionScreen extends StatelessWidget {
  const NightSelectionScreen({super.key});

  void _checkAndNavigate(BuildContext context, Widget destination) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.activeNightId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya tienes una noche activa. Finalízala antes de crear o unirte a otra.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    // Eliminamos Scaffold y AppBar
    return Container(
      color: AfterlifeColors.background,
      child: Center(
        child: Padding(
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
                onTap: () => _checkAndNavigate(context, const CreateNightScreen()),
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
                onTap: () => _checkAndNavigate(context, const JoinNightScreen()),
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
      ),
    );
  }
}
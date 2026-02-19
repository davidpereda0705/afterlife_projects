// lib/features/home/home_screen.dart
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/BottomNav.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Bottom Navigation Items
  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.nightlight_outlined,
      selectedIcon: Icons.nightlight_round,
      label: 'Noches',
    ),
    BottomNavItem(
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events,
      label: 'Logros',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  // Datos de ejemplo del usuario
  final String userName = 'Carlos';
  final int userLevel = 12;
  final int nightsCompleted = 8;
  final int challengesCompleted = 47;
  final int groupsCount = 12;

  // NOCHES EN ESPERA (LOBBY)
  final List<Map<String, dynamic>> _pendingNights = [
    {
      'groupName': 'Los Desvelados',
      'hostName': 'Ana',
      'nightName': 'Viernes de Locura',
      'time': '22:30',
      'currentPlayers': 3,
      'maxPlayers': 8,
      'groupMembers': ['AN', 'CR', 'MJ', 'JP', 'LM', 'PA', 'SS', 'DL'],
      'joinedFriends': ['AN', 'MJ', 'LM'],
    },
    {
      'groupName': 'Fiesteros Nocturnos',
      'hostName': 'Luis',
      'nightName': 'Sábado Nocturno',
      'time': '23:00',
      'currentPlayers': 2,
      'maxPlayers': 6,
      'groupMembers': ['LM', 'PA', 'SS', 'RC', 'MV'],
      'joinedFriends': ['LM', 'PA'],
    },
    {
      'groupName': 'Party Animals',
      'hostName': 'Pedro',
      'nightName': 'Previa Viernes',
      'time': '21:00',
      'currentPlayers': 4,
      'maxPlayers': 4,
      'groupMembers': ['PG', 'LT', 'MS', 'JV'],
      'joinedFriends': ['PG', 'LT', 'MS', 'JV'],
    },
  ];

  // Logros próximos
  final List<Map<String, dynamic>> _upcomingAchievements = [
    {'title': 'SOCIAL', 'icon': Icons.people, 'progress': 0.8},
    {'title': 'LEYENDA', 'icon': Icons.stars, 'progress': 0.3},
    {'title': 'FIESTERO', 'icon': Icons.nightlife, 'progress': 0.6},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text(
          'Afterlife',
          style: AfterlifeTextTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AfterlifeAvatar(
              initials: 'CR',
              status: AvatarStatus.online,
              size: 40,
              showStatusIndicator: true,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card de perfil rápido
          _buildProfileCard(),
          
          const SizedBox(height: 24),
          
          // Sección de noches en espera
          _buildPendingNightsSection(),
          
          const SizedBox(height: 16),
          
          // Botón para crear nueva noche
          _buildCreateNightButton(),
          
          const SizedBox(height: 20), // Espacio extra al final
        ],
      ),
      bottomNavigationBar: AfterlifeBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }

  // ===== CARD DE PERFIL RÁPIDO =====
  Widget _buildProfileCard() {
    return AfterlifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AfterlifeAvatar(
                initials: 'CR',
                status: AvatarStatus.online,
                size: 70,
                showStatusIndicator: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AfterlifeTextTheme.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.electricLilac.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AfterlifeColors.electricLilac.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'NIVEL $userLevel',
                        style: AfterlifeTextTheme.labelSmall.copyWith(
                          color: AfterlifeColors.electricLilac,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                value: nightsCompleted.toString(),
                label: 'Noches',
                icon: Icons.nightlight_round,
                color: AfterlifeColors.neonPink,
              ),
              _buildStatColumn(
                value: challengesCompleted.toString(),
                label: 'Retos',
                icon: Icons.emoji_events,
                color: AfterlifeColors.cyanBlue,
              ),
              _buildStatColumn(
                value: groupsCount.toString(),
                label: 'Grupos',
                icon: Icons.group,
                color: AfterlifeColors.acidGreen,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'PRÓXIMOS LOGROS',
            style: AfterlifeTextTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _upcomingAchievements.map((achievement) {
              return _buildAchievementProgress(
                icon: achievement['icon'],
                title: achievement['title'],
                progress: achievement['progress'],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===== SECCIÓN DE NOCHES EN ESPERA =====
  Widget _buildPendingNightsSection() {
    // Filtrar solo noches disponibles (no llenas y donde el usuario no está)
    final availableNights = _pendingNights.where((night) {
      final isNotFull = night['currentPlayers'] < night['maxPlayers'];
      final userNotJoined = !night['joinedFriends'].contains('CR');
      return isNotFull && userNotJoined;
    }).toList();

    if (availableNights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AfterlifeColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AfterlifeColors.electricLilac.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.nightlight_round,
              color: AfterlifeColors.electricLilac.withOpacity(0.5),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay noches en espera',
              style: AfterlifeTextTheme.bodyLarge.copyWith(
                color: AfterlifeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea una nueva noche o espera a que tus amigos te inviten',
              textAlign: TextAlign.center,
              style: AfterlifeTextTheme.bodySmall.copyWith(
                color: AfterlifeColors.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AfterlifeColors.neonOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: AfterlifeColors.neonOrange,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'NOCHES EN ESPERA (${availableNights.length})',
                style: AfterlifeTextTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AfterlifeColors.neonOrange,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Lista de noches disponibles
        Column(
          children: availableNights.map((night) => _buildPendingNightCard(night)).toList(),
        ),
      ],
    );
  }

  // ===== CARD DE NOCHE EN ESPERA =====
  Widget _buildPendingNightCard(Map<String, dynamic> night) {
    final bool isFull = night['currentPlayers'] >= night['maxPlayers'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AfterlifeColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AfterlifeColors.neonOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grupo y host
          Row(
            children: [
              // Icono del grupo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AfterlifeColors.electricLilacGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.group, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      night['groupName'],
                      style: AfterlifeTextTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AfterlifeColors.neonOrange,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Anfitrión: ${night['hostName']}',
                          style: AfterlifeTextTheme.bodySmall.copyWith(
                            color: AfterlifeColors.neonOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Hora
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AfterlifeColors.neonOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  night['time'],
                  style: AfterlifeTextTheme.labelSmall.copyWith(
                    color: AfterlifeColors.neonOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Nombre de la noche
          Row(
            children: [
              Icon(
                Icons.nightlife,
                color: AfterlifeColors.neonOrange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                night['nightName'],
                style: AfterlifeTextTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Jugadores confirmados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jugadores: ${night['currentPlayers']}/${night['maxPlayers']}',
                style: AfterlifeTextTheme.bodySmall.copyWith(
                  color: AfterlifeColors.textSecondary,
                ),
              ),
              if (!isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.acidGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PLAZAS DISPONIBLES',
                    style: AfterlifeTextTheme.labelSmall.copyWith(
                      color: AfterlifeColors.acidGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Avatares de los que ya se unieron
          SizedBox(
            height: 32,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ...List.generate(
                  night['joinedFriends'].length > 5 ? 5 : night['joinedFriends'].length,
                  (index) {
                    return Positioned(
                      left: index * 20.0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AfterlifeColors.background,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AfterlifeAvatar(
                          initials: night['joinedFriends'][index],
                          status: AvatarStatus.online,
                          size: 28,
                          showStatusIndicator: true,
                        ),
                      ),
                    );
                  },
                ),
                if (night['joinedFriends'].length > 5)
                  Positioned(
                    left: 5 * 20.0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AfterlifeColors.electricLilac.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AfterlifeColors.background,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '+${night['joinedFriends'].length - 5}',
                          style: AfterlifeTextTheme.labelSmall.copyWith(
                            color: AfterlifeColors.electricLilac,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón para unirse
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFull ? null : () {
                print('Unirse a la noche: ${night['nightName']}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Te has unido a ${night['nightName']}'),
                    backgroundColor: AfterlifeColors.acidGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull 
                    ? Colors.grey.withOpacity(0.3)
                    : AfterlifeColors.neonOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isFull ? 'NOCHE COMPLETA' : 'UNIRSE A LA NOCHE',
                style: AfterlifeTextTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== BOTÓN PARA CREAR NOCHE =====
  Widget _buildCreateNightButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          print('Crear nueva noche');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AfterlifeColors.electricLilac,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            const SizedBox(width: 8),
            Text(
              'CREAR NUEVA NOCHE',
              style: AfterlifeTextTheme.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== COLUMNA DE ESTADÍSTICA =====
  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AfterlifeTextTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AfterlifeTextTheme.labelSmall.copyWith(
            color: AfterlifeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ===== LOGRO CON PROGRESO =====
  Widget _buildAchievementProgress({
    required IconData icon,
    required String title,
    required double progress,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AfterlifeColors.electricLilac.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AfterlifeColors.electricLilac,
                ),
                strokeWidth: 3,
              ),
            ),
            Icon(
              icon,
              color: AfterlifeColors.electricLilac.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AfterlifeTextTheme.labelSmall.copyWith(
            color: AfterlifeColors.textSecondary,
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: AfterlifeTextTheme.labelSmall.copyWith(
            color: AfterlifeColors.electricLilac,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
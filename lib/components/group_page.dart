// lib/screens/group_page.dart
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/chat_page.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0: Todos, 1: Online, 2: Noches
  
  // Datos de amigos mejorados
  final List<Map<String, dynamic>> _friends = [
    {
      'name': 'Marc_After',
      'status': 'online',
      'message': '¡Mañana se sale! 🎉',
      'time': 'Ahora',
      'initials': 'MA',
      'unread': 3,
      'lastSeen': null,
      'typing': false,
    },
    {
      'name': 'Elena_Night',
      'status': 'online',
      'message': '¿A qué hora quedamos?',
      'time': '10:30',
      'initials': 'EN',
      'unread': 0,
      'lastSeen': null,
      'typing': true,
    },
    {
      'name': 'Pau_Vibes',
      'status': 'away',
      'message': 'Visto hace 2h',
      'time': 'Hace 2h',
      'initials': 'PV',
      'unread': 0,
      'lastSeen': DateTime.now().subtract(const Duration(hours: 2)),
      'typing': false,
    },
    {
      'name': 'Alex_Party',
      'status': 'online',
      'message': '🎧 Enviando audio...',
      'time': '10:15',
      'initials': 'AP',
      'unread': 1,
      'lastSeen': null,
      'typing': false,
    },
    {
      'name': 'Laura_Nox',
      'status': 'inNight',
      'message': '🔴 En una noche',
      'time': '23:45',
      'initials': 'LN',
      'unread': 5,
      'lastSeen': null,
      'typing': false,
    },
    {
      'name': 'David_Fiesta',
      'status': 'offline',
      'message': 'Visto hace 1 día',
      'time': 'Ayer',
      'initials': 'DF',
      'unread': 0,
      'lastSeen': DateTime.now().subtract(const Duration(days: 1)),
      'typing': false,
    },
    {
      'name': 'Sara_Glow',
      'status': 'online',
      'message': '¿Vais a la fiesta?',
      'time': '10:05',
      'initials': 'SG',
      'unread': 2,
      'lastSeen': null,
      'typing': false,
    },
    {
      'name': 'Javi_Rave',
      'status': 'inNight',
      'message': '🔴 En Techno Loft',
      'time': '00:30',
      'initials': 'JR',
      'unread': 0,
      'lastSeen': null,
      'typing': false,
    },
  ];

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // Función auxiliar para obtener el estado del avatar
  AvatarStatus _getAvatarStatus(String status) {
    switch (status) {
      case 'online':
        return AvatarStatus.online;
      case 'inNight':
        return AvatarStatus.inNight;
      case 'away':
        return AvatarStatus.offline;
      default:
        return AvatarStatus.offline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMUNIDAD',
              style: AfterlifeTextTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Conecta con tus amigos',
              style: AfterlifeTextTheme.bodySmall.copyWith(
                color: AfterlifeColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Badge de invitaciones
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.people_outline, color: AfterlifeColors.electricPurple),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.neonPink,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda mejorada
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AfterlifeColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AfterlifeColors.electricLilac.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: AfterlifeColors.electricLilac, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AfterlifeColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Buscar amigos...',
                        hintStyle: TextStyle(color: AfterlifeColors.textDisabled),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close, color: AfterlifeColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ],
              ),
            ),
          ),

          // Tabs de filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todos', 0, AfterlifeColors.cyanBlue),
                const SizedBox(width: 8),
                _buildFilterChip('Online', 1, AfterlifeColors.acidGreen),
                const SizedBox(width: 8),
                _buildFilterChip('En noche', 2, AfterlifeColors.electricLilac),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de amigos filtrada
          Expanded(
            child: _buildFriendsList(),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            // Crear nuevo grupo o búsqueda de amigos
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Buscar nuevos amigos'),
                backgroundColor: AfterlifeColors.electricLilac,
              ),
            );
          },
          backgroundColor: AfterlifeColors.electricLilac,
          icon: const Icon(Icons.group_add, color: Colors.white),
          label: const Text(
            'NUEVO GRUPO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, Color color) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : color.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    // Aplicar filtros
    var filteredFriends = _friends.where((friend) {
      final matchesSearch = _searchQuery.isEmpty || 
          friend['name'].toLowerCase().contains(_searchQuery);
      
      if (!matchesSearch) return false;
      
      switch (_selectedTab) {
        case 1: // Online
          return friend['status'] == 'online';
        case 2: // En noche
          return friend['status'] == 'inNight';
        default: // Todos
          return true;
      }
    }).toList();

    // Ordenar: online primero, luego en noche, luego away, luego offline
    filteredFriends.sort((a, b) {
      const order = {'online': 0, 'inNight': 1, 'away': 2, 'offline': 3};
      return order[a['status']]!.compareTo(order[b['status']]!);
    });

    if (filteredFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 60,
              color: AfterlifeColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron amigos',
              style: AfterlifeTextTheme.bodyLarge.copyWith(
                color: AfterlifeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con otra búsqueda',
              style: TextStyle(color: AfterlifeColors.textDisabled),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        return _buildAdvancedFriendTile(friend);
      },
    );
  }

  Widget _buildAdvancedFriendTile(Map<String, dynamic> friend) {
    Color statusColor;
    String statusText;
    
    switch (friend['status']) {
      case 'online':
        statusColor = AfterlifeColors.acidGreen;
        statusText = 'En línea';
        break;
      case 'inNight':
        statusColor = AfterlifeColors.electricLilac;
        statusText = 'En una noche';
        break;
      case 'away':
        statusColor = AfterlifeColors.neonOrange;
        statusText = 'Ausente';
        break;
      default:
        statusColor = AfterlifeColors.textDisabled;
        statusText = 'Desconectado';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage(userName: friend['name'])),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: AfterlifeCard(
          child: Stack(
            children: [
              // Indicador de mensajes no leídos
              if (friend['unread'] > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AfterlifeColors.neonPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      friend['unread'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Avatar con animación si está escribiendo - VERSIÓN CORREGIDA
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AfterlifeAvatar(
                            initials: friend['initials'],
                            status: _getAvatarStatus(friend['status']),
                            size: 60,
                            showStatusIndicator: true,
                          ),
                          if (friend['typing'])
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AfterlifeColors.cyanBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AfterlifeColors.background,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Información del amigo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                friend['name'],
                                style: AfterlifeTextTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Último mensaje con indicador de tipado
                          Row(
                            children: [
                              if (friend['typing'])
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  child: const Icon(
                                    Icons.more_horiz,
                                    color: Color(0xFF06B6D4),
                                    size: 14,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  friend['typing'] 
                                      ? 'Escribiendo...' 
                                      : friend['message'],
                                  style: TextStyle(
                                    color: friend['typing'] 
                                        ? AfterlifeColors.cyanBlue
                                        : AfterlifeColors.textSecondary,
                                    fontSize: 13,
                                    fontStyle: friend['typing'] 
                                        ? FontStyle.italic 
                                        : FontStyle.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Hora del último mensaje
                          Text(
                            friend['time'],
                            style: TextStyle(
                              color: AfterlifeColors.textDisabled,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Icono de chat
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.cyanBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AfterlifeColors.cyanBlue,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
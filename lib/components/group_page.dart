import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/chat_page.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/services/friend_service.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> with TickerProviderStateMixin {
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0: amigos, 1: solicitudes, 2: buscar
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

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

  AvatarStatus _getAvatarStatus(String status) {
    switch (status) {
      case 'online':
        return AvatarStatus.online;
      case 'inNight':
        return AvatarStatus.inNight;
      default:
        return AvatarStatus.offline;
    }
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _friendService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _sendRequest(String uid, String name) async {
    try {
      await _friendService.sendFriendRequest(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada a $name'), backgroundColor: Colors.green),
      );
      _searchController.clear();
      _searchResults = [];
      setState(() => _searchQuery = '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _acceptRequest(String uid, String name) async {
    await _friendService.acceptFriendRequest(uid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ahora eres amigo de $name'), backgroundColor: Colors.green),
    );
  }

  void _rejectRequest(String uid, String name) async {
    await _friendService.rejectFriendRequest(uid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solicitud rechazada'), backgroundColor: Colors.orange),
    );
  }

  void _removeFriend(String uid, String name) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AfterlifeColors.surfaceDark,
        title: const Text('Eliminar amigo', style: TextStyle(color: Colors.white)),
        content: Text('¿Seguro que quieres eliminar a $name de tus amigos?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _friendService.removeFriend(uid);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name ya no es tu amigo'), backgroundColor: Colors.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AfterlifeColors.background,
      child: Column(
        children: [
          // Tabs de filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('AMIGOS', 0, AfterlifeColors.cyanBlue),
                const SizedBox(width: 8),
                _buildFilterChip('SOLICITUDES', 1, AfterlifeColors.neonOrange),
                const SizedBox(width: 8),
                _buildFilterChip('BUSCAR', 2, AfterlifeColors.electricLilac),
              ],
            ),
          ),

          // Barra de búsqueda (solo visible en pestaña de buscar)
          if (_selectedTab == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AfterlifeColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
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
                          hintText: 'Buscar por nombre...',
                          hintStyle: TextStyle(color: AfterlifeColors.textDisabled),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _searchUsers(value);
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close, color: AfterlifeColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _searchUsers('');
                        },
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Contenido según pestaña seleccionada
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, Color color) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          if (index != 2) {
            _searchController.clear();
            _searchQuery = '';
            _searchResults = [];
          }
        },
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

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildFriendsList();
      case 1:
        return _buildRequestsList();
      case 2:
        return _buildSearchList();
      default:
        return const SizedBox();
    }
  }

  // ==================== PESTAÑA DE AMIGOS ====================
  Widget _buildFriendsList() {
    return StreamBuilder(
      stream: _friendService.getFriends(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white70)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final friends = snapshot.data!;
        
        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 60, color: AfterlifeColors.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No tienes amigos aún',
                  style: AfterlifeTextTheme.bodyLarge.copyWith(color: AfterlifeColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ve a la pestaña "BUSCAR" para añadir amigos',
                  style: TextStyle(color: AfterlifeColors.textDisabled),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return _buildFriendTile(friend);
          },
        );
      },
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend) {
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AfterlifeAvatar(
                  initials: friend['initials'],
                  status: _getAvatarStatus(friend['status']),
                  size: 55,
                  showStatusIndicator: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            friend['name'],
                            style: AfterlifeTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
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
                              style: TextStyle(color: statusColor, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend['message'],
                        style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: AfterlifeColors.textSecondary),
                  onPressed: () => _removeFriend(friend['uid'], friend['name']),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== PESTAÑA DE SOLICITUDES ====================
  Widget _buildRequestsList() {
    return StreamBuilder(
      stream: _friendService.getFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white70)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_outlined, size: 60, color: AfterlifeColors.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No hay solicitudes pendientes',
                  style: AfterlifeTextTheme.bodyLarge.copyWith(color: AfterlifeColors.textSecondary),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AfterlifeCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      AfterlifeAvatar(
                        initials: req['initials'],
                        status: AvatarStatus.online,
                        size: 50,
                        showStatusIndicator: false,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req['name'],
                              style: AfterlifeTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quiere ser tu amigo',
                              style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: AfterlifeColors.acidGreen),
                            onPressed: () => _acceptRequest(req['uid'], req['name']),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: AfterlifeColors.neonPink),
                            onPressed: () => _rejectRequest(req['uid'], req['name']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== PESTAÑA DE BÚSQUEDA ====================
  Widget _buildSearchList() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 60, color: AfterlifeColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No se encontraron usuarios',
              style: AfterlifeTextTheme.bodyLarge.copyWith(color: AfterlifeColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con otro nombre',
              style: TextStyle(color: AfterlifeColors.textDisabled),
            ),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: AfterlifeColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'Busca usuarios por nombre',
              style: AfterlifeTextTheme.bodyLarge.copyWith(color: AfterlifeColors.textSecondary),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AfterlifeCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AfterlifeAvatar(
                    initials: user['initials'],
                    status: AvatarStatus.online,
                    size: 50,
                    showStatusIndicator: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: AfterlifeTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['email'],
                          style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _sendRequest(user['uid'], user['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AfterlifeColors.acidGreen,
                      minimumSize: const Size(80, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('AÑADIR', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
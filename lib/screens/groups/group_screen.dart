// lib/screens/group_page.dart (mueve este archivo a screens/ si está en components/)
import 'package:afterlife_projects/screens/chat/chat_screen.dart';
import 'package:afterlife_projects/providers/user_provider.dart';
import 'package:afterlife_projects/services/chat_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/widgets/common/afterlife_avatar.dart';
import 'package:afterlife_projects/widgets/cards/afterlife_card.dart';
import 'package:afterlife_projects/services/friend_service.dart';
import 'package:afterlife_projects/screens/groups/friend_profile_screen.dart';
import 'package:afterlife_projects/services/achievement_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> with TickerProviderStateMixin {
  final FriendService _friendService = FriendService();
  final ChatService _chatService = ChatService();
  final AchievementService _achievementService = AchievementService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0: amigos, 1: solicitudes, 2: buscar
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isNavigating = false;
  String? _loadingFriendId;

  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada a $name'), backgroundColor: AfterlifeColors.acidGreen),
      );
      _searchController.clear();
      _searchResults = [];
      setState(() => _searchQuery = '');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _acceptRequest(String uid, String name) async {
    try {
      await _friendService.acceptFriendRequest(uid);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ahora eres amigo de $name'), backgroundColor: AfterlifeColors.acidGreen),
      );

      // Verificar logros después de aceptar
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      // Esperar un poco para que Firestore actualice el documento
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await userProvider.refresh();
      final userData = userProvider.userData;
      final friendsCount = userData?['friendsCount'] ?? 0;

      final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
        userId: userId,
        nightsCompleted: userData?['nightsCompleted'] ?? 0,
        challengesCompleted: userData?['challengesCompleted'] ?? 0,
        level: userData?['level'] ?? 0,
        friendsCount: friendsCount,
        photosUploaded: userData?['photosUploaded'] ?? 0,
        nightsCreated: userData?['nightsCreated'] ?? 0,
      );

      if (newlyUnlocked.isNotEmpty && mounted) {
        final achievementNames = newlyUnlocked.map((a) => a.title).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ¡Logros desbloqueados: $achievementNames!'),
            backgroundColor: AfterlifeColors.acidGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        await userProvider.refresh();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _rejectRequest(String uid, String name) async {
    try {
      await _friendService.rejectFriendRequest(uid);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud rechazada'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _removeFriend(String uid, String name) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: Text('¿Seguro que quieres eliminar a $name de tus amigos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _friendService.removeFriend(uid);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name ya no es tu amigo'), backgroundColor: Theme.of(context).colorScheme.error),
                );

                // Verificar logros después de eliminar (opcional, pero útil para actualizar progreso)
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) return;
                await Future.delayed(const Duration(milliseconds: 500));
                if (!mounted) return;
                await userProvider.refresh();
                final userData = userProvider.userData;
                final friendsCount = userData?['friendsCount'] ?? 0;

                final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
                  userId: userId,
                  nightsCompleted: userData?['nightsCompleted'] ?? 0,
                  challengesCompleted: userData?['challengesCompleted'] ?? 0,
                  level: userData?['level'] ?? 0,
                  friendsCount: friendsCount,
                  photosUploaded: userData?['photosUploaded'] ?? 0,
                  nightsCreated: userData?['nightsCreated'] ?? 0,
                );

                if (newlyUnlocked.isNotEmpty && mounted) {
                  final achievementNames = newlyUnlocked.map((a) => a.title).join(', ');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 ¡Logros desbloqueados: $achievementNames!'),
                      backgroundColor: AfterlifeColors.acidGreen,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  await userProvider.refresh();
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AfterlifeColors.electricLilac.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search, color: AfterlifeColors.electricLilac, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
                          hintStyle: TextStyle(color: Theme.of(context).disabledColor),
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
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : color.withValues(alpha: 0.7),
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
          return Center(child: Text('Error: ${snapshot.error}'));
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
                Icon(Icons.people_outline, size: 60, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No tienes amigos aún', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Ve a la pestaña "BUSCAR" para añadir amigos', style: Theme.of(context).textTheme.bodySmall),
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
        statusColor = Theme.of(context).disabledColor;
        statusText = 'Desconectado';
    }

    return GestureDetector(
      onTap: () async {
        if (_isNavigating) return;
        
        setState(() {
          _isNavigating = true;
          _loadingFriendId = friend['uid'];
        });

        try {
          final chatId = await _chatService.getOrCreateChat(
            friend['uid'],
            friend['name']
          );
          
          if (!mounted) return;
          
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                otherUserId: friend['uid'],
                otherUserName: friend['name'],
              ),
            ),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isNavigating = false;
              _loadingFriendId = null;
            });
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: AfterlifeCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendProfileScreen(
                          uid: friend['uid'],
                          friendName: friend['name'],
                        ),
                      ),
                    );
                  },
                  child: AfterlifeAvatar(
                    initials: friend['initials'],
                    status: _getAvatarStatus(friend['status']),
                    size: 55,
                    showStatusIndicator: true,
                  ),
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
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (_loadingFriendId == friend['uid'])
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AfterlifeColors.electricPurple),
                              ),
                            ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
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
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
          return Center(child: Text('Error: ${snapshot.error}'));
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
                Icon(Icons.person_add_outlined, size: 60, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No hay solicitudes pendientes', style: Theme.of(context).textTheme.bodyLarge),
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
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quiere ser tu amigo',
                              style: Theme.of(context).textTheme.bodySmall,
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
            Icon(Icons.person_search, size: 60, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No se encontraron usuarios', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Prueba con otro nombre', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Busca usuarios por nombre', style: Theme.of(context).textTheme.bodyLarge),
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
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // Email oculto por privacidad; si lo necesitas, usa un campo alternativo
                        // Text(user['email'], style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
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
}
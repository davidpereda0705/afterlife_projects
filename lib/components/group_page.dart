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
  int _selectedTab = 0;
  
  final List<Map<String, dynamic>> _friends = [
    // ... tus datos de amigos (igual que antes)
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
    // Eliminamos Scaffold y AppBar
    return Container(
      color: AfterlifeColors.background,
      child: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
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

          // Lista de amigos
          Expanded(
            child: _buildFriendsList(),
          ),
        ],
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
    // ... tu lógica de filtrado y construcción de la lista (igual que antes)
    // No la repito aquí por brevedad, pero debe ser la misma que tenías.
    // Solo asegúrate de que NO tenga Scaffold ni AppBar.
    return Container(); // ← esto es un placeholder, pon aquí tu código real
  }

  // El resto de métodos (_buildAdvancedFriendTile, _getInitials, etc.) se mantienen igual
}
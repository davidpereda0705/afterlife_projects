// lib/screens/join_night_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/night_service.dart';
import '../providers/user_provider.dart';
import '../theme/colors.dart';
import 'night_game_screen.dart';

class JoinNightScreen extends StatefulWidget {
  const JoinNightScreen({super.key});

  @override
  State<JoinNightScreen> createState() => _JoinNightScreenState();
}

class _JoinNightScreenState extends State<JoinNightScreen> {
  final NightService _nightService = NightService();
  List<Map<String, dynamic>> _availableNights = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableNights();
  }

  Future<void> _loadAvailableNights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final nights = await _nightService.getAvailableNights();
      setState(() {
        _availableNights = nights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinNight(Map<String, dynamic> night) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('Debes iniciar sesión', Theme.of(context).colorScheme.error);
      return;
    }

    // Obtener el provider para comprobar si ya tiene noche activa
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.activeNightId != null) {
      _showSnackBar('Ya tienes una noche activa', Theme.of(context).colorScheme.error);
      return;
    }

    final username = userProvider.userData?['username'] ?? 'Usuario';
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.substring(0, 1).toUpperCase();

    try {
      // Verificar que la noche aún existe y no está llena
      final nightDoc = await _nightService.getNightById(night['id']);
      if (!mounted) return;
      if (nightDoc == null) {
        _showSnackBar('La noche ya no existe', Theme.of(context).colorScheme.error);
        _loadAvailableNights();
        return;
      }

      final currentPlayers = (nightDoc['players'] as List? ?? []).length;
      final maxPlayers = nightDoc['maxPlayers'] ?? 0;
      if (currentPlayers >= maxPlayers) {
        _showSnackBar('La noche está llena', Theme.of(context).colorScheme.error);
        _loadAvailableNights();
        return;
      }

      // Unirse a la noche
      await _nightService.joinNight(night['id'], userId, username, initials);
      // Marcar noche activa para el usuario
      await _nightService.setActiveNightForUser(userId, night['id']);
      // Refrescar UserProvider para actualizar el badge
      await userProvider.refresh();

      if (!mounted) return;
      _showSnackBar('Te has unido a ${night['name']}', AfterlifeColors.acidGreen);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NightGameScreen(nightId: night['id']),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al unirse: $e', Theme.of(context).colorScheme.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Unirse a Noche',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NOCHES DISPONIBLES',
              style: TextStyle(
                color: AfterlifeColors.neonPink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
       Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAvailableNights,
              style: ElevatedButton.styleFrom(
                backgroundColor: AfterlifeColors.electricLilac,
              ),
              child: const Text('REINTENTAR'),
            ),
          ],
        ),
      );
    }
    if (_availableNights.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: _availableNights.length,
      itemBuilder: (context, index) => _buildNightCard(_availableNights[index]),
    );
  }

  Widget _buildNightCard(Map<String, dynamic> night) {
    final players = night['players'] as List? ?? [];
    final currentPlayers = players.length;
    final maxPlayers = night['maxPlayers'] ?? 0;
    final bool isFull = currentPlayers >= maxPlayers;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull
              ? Theme.of(context).disabledColor.withValues(alpha: 0.3)
              : AfterlifeColors.neonPink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AfterlifeColors.electricLilac, AfterlifeColors.neonPink],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    night['hostInitials'] ?? '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      night['name'] ?? 'Sin nombre',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${night['hostName'] ?? ''} · ${night['groupName'] ?? ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 16),
              const SizedBox(width: 4),
              Text(
                '${night['day'] ?? ''} · ${night['time'] ?? ''}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const Spacer(),
              if (!isFull)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.acidGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DISPONIBLE',
                    style: TextStyle(
                      color: AfterlifeColors.acidGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMPLETA',
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
              const SizedBox(width: 4),
              Text(
                '$currentPlayers/$maxPlayers',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFull ? null : () => _joinNight(night),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull
                    ? Theme.of(context).disabledColor.withValues(alpha: 0.3)
                    : AfterlifeColors.neonPink,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isFull ? 'COMPLETA' : 'UNIRSE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlight_round,
            size: 60,
            color: AfterlifeColors.electricLilac.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay noches disponibles',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una nueva noche o vuelve más tarde',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

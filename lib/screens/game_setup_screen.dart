// lib/screens/game_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/games/truth_or_drinks_game.dart';
import 'package:afterlife_projects/games/yo_nunca_nunca.dart';
import 'package:afterlife_projects/games/would_you_rether_game.dart';
import 'package:afterlife_projects/games/reto_rapido.dart';

class GameSetupScreen extends StatefulWidget {
  final String gameRoute;
  const GameSetupScreen({super.key, required this.gameRoute});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final List<Map<String, dynamic>> _players = [];
  final TextEditingController _nameController = TextEditingController();

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_players.any((p) => p['name'] == name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese nombre ya está en la lista'), backgroundColor: Colors.orange),
      );
      return;
    }
    final initials = name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').join('').toUpperCase();
    setState(() {
      _players.add({'name': name, 'initials': initials.isNotEmpty ? initials : name[0].toUpperCase()});
      _nameController.clear();
    });
  }

  void _removePlayer(int index) {
    setState(() => _players.removeAt(index));
  }

  void _startGame() {
    if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mínimo 2 jugadores'), backgroundColor: Colors.red),
      );
      return;
    }

    Widget game;
    switch (widget.gameRoute) {
      case 'truth_or_drink':
        game = TruthOrDrinkGame(players: _players);
        break;
      case 'yo_nunca':
        game = YoNuncaGame(players: _players);
        break;
      case 'would_you_rather':
        game = WouldYouRatherGame(players: _players);
        break;
      case 'reto_rapido':
        game = RetoRapidoGame(players: _players);
        break;
      default:
        Navigator.pop(context);
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => game),
    );
  }

  String get _gameTitle {
    switch (widget.gameRoute) {
      case 'truth_or_drink':
        return 'VERDAD O RETO';
      case 'yo_nunca':
        return 'YO NUNCA';
      case 'would_you_rather':
        return '¿QUÉ PREFIERES?';
      case 'reto_rapido':
        return 'RETO RÁPIDO';
      default:
        return 'MINIJUEGO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _gameTitle,
          style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JUGADORES',
              style: AfterlifeTextTheme.titleSmall.copyWith(
                color: AfterlifeColors.electricLilac,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AfterlifeColors.electricLilac.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nombre del jugador',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AfterlifeColors.acidGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('AÑADIR'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_players.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.people_outline, size: 60, color: AfterlifeColors.textDisabled),
                    const SizedBox(height: 16),
                    Text(
                      'Añade al menos 2 jugadores',
                      style: TextStyle(color: AfterlifeColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AfterlifeColors.cyanBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AfterlifeColors.cyanBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                player['initials'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              player['name'],
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.redAccent),
                            onPressed: () => _removePlayer(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            AfterButton(
              label: 'EMPEZAR JUEGO',
              color: AfterlifeColors.electricLilac,
              onPressed: _startGame,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${_players.length} jugador${_players.length != 1 ? 'es' : ''}',
                style: TextStyle(color: AfterlifeColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

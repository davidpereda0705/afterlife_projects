import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/widgets/cards/afterlife_card.dart';
import 'package:afterlife_projects/widgets/common/after_button.dart';

class YoNuncaGame extends StatefulWidget {
  final List<Map<String, dynamic>>? players;
  const YoNuncaGame({super.key, this.players});

  @override
  State<YoNuncaGame> createState() => _YoNuncaGameState();
}

class _YoNuncaGameState extends State<YoNuncaGame> {
  late List<Map<String, dynamic>> _players;

  // Frases (puedes usar las que ya tienes)
  final List<String> _frases = [
    "Yo nunca nunca he besado a alguien de esta sala.",
    "Yo nunca nunca he enviado un mensaje por error a mi ex.",
    "Yo nunca nunca he fingido estar sobrio delante de mis padres.",
    "Yo nunca nunca me he despertado sin saber dónde estaba.",
    "Yo nunca nunca he mentido en este juego.",
    "Yo nunca nunca he llorado en una discoteca.",
    "Yo nunca nunca he tenido un perfil falso en redes sociales.",
    "Yo nunca nunca me he liado con el/la ex de un amigo.",
    "Yo nunca nunca he bebido directamente de la botella de otro.",
    "Yo nunca nunca he dicho que no iba a salir y he acabado cerrando la discoteca.",
    "Yo nunca nunca me he equivocado de baño en un bar.",
    "Yo nunca nunca he robado un vaso de un local.",
    "Yo nunca nunca me he caído en público estando de fiesta.",
    "Yo nunca nunca he perdido el móvil o la cartera de fiesta.",
    "Yo nunca nunca he olvidado el nombre de la persona con la que me estaba besando.",
    "Yo nunca nunca he subido una storie borracho y me he arrepentido al despertar.",
    "Yo nunca nunca he bailado encima de una mesa o de la barra.",
    "Yo nunca nunca he mentido para que me dejaran entrar en un reservado.",
    "Yo nunca nunca he usado una app de citas estando dentro de una discoteca.",
    "Yo nunca nunca he hecho un 'simpa' (irse sin pagar).",
    "Yo nunca nunca me he colado en una fiesta privada.",
    "Yo nunca nunca he besado a más de dos personas en la misma noche.",
    "Yo nunca nunca he intentado entrar a un club con el DNI de otra persona.",
    "Yo nunca nunca me he liado con el/la ex de alguien de esta sala.",
    "Yo nunca nunca he tenido un lío en los baños de un bar/discoteca.",
    "Yo nunca nunca he despertado en una casa que no era la mía sin saber cómo llegué.",
    "Yo nunca nunca he enviado un mensaje 'picante' a la persona equivocada.",
    "Yo nunca nunca he buscado el Instagram de mi ex mientras bebía.",
    "Yo nunca nunca he hecho un trío o algo parecido.",
    "Yo nunca nunca he tenido una 'amigo con derechos' en este grupo.",
    "Yo nunca nunca he buscado el nombre de alguien que me gusta en el móvil de un amigo.",
    "Yo nunca nunca he sido pillado/a haciendo algo indebido en un coche.",
    "Yo nunca nunca he mentido en este juego para no beber.",
    "Yo nunca nunca he vomitado en la calle y he seguido de fiesta como si nada.",
    "Yo nunca nunca he fingido una llamada para escapar de una cita horrible.",
    "Yo nunca nunca me he sentido atraído/a por un familiar de un amigo.",
    "Yo nunca nunca he hecho algo de lo que me arrepiento totalmente hoy."
  ];

  int _currentIndex = 0;
  bool _gameFinished = false;

  @override
  void initState() {
    super.initState();
    if (widget.players != null && widget.players!.isNotEmpty) {
      _players = widget.players!.map((p) => {
        'name': p['name'],
        'initials': p['initials'],
        'points': 0,
      }).toList();
    } else {
      _players = [
        {'name': 'Carlos', 'initials': 'CR', 'points': 0},
        {'name': 'Ana', 'initials': 'AN', 'points': 0},
        {'name': 'María', 'initials': 'MJ', 'points': 0},
        {'name': 'Luis', 'initials': 'LP', 'points': 0},
      ];
    }
    _frases.shuffle(); // Mezclar al inicio
  }

  void _addPoint(int index) {
    setState(() {
      _players[index]['points'] = (_players[index]['points'] as int) + 1;
    });
  }

  void _nextFrase() {
    if (_currentIndex < _frases.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Fin del juego
      setState(() {
        _gameFinished = true;
      });
    }
  }

  void _resetGame() {
    setState(() {
      // Reiniciar contadores
      for (var p in _players) {
        p['drinks'] = 0;
      }
      _frases.shuffle();
      _currentIndex = 0;
      _gameFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameFinished) {
      return _buildResultsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('YO NUNCA', style: AfterlifeTextTheme.headlineMedium),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Barra de progreso
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _frases.length,
                backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                color: AfterlifeColors.neonPink,
              ),
              const SizedBox(height: 8),
              Text(
                'Frase ${_currentIndex + 1}/${_frases.length}',
                style: AfterlifeTextTheme.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
              const SizedBox(height: 20),

              // Lista de jugadores
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AfterlifeColors.neonPink.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                player['initials'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              player['name'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AfterlifeColors.neonOrange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${player['points']} ⭐',
                              style: const TextStyle(color: AfterlifeColors.neonOrange, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AfterlifeColors.neonPink),
                            onPressed: () => _addPoint(index),
                            tooltip: 'Añadir punto',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Tarjeta de la frase
              Expanded(
                flex: 3,
                child: AfterlifeCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: AfterlifeColors.neonPink,
                          size: 50,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "YO NUNCA NUNCA...",
                          style: AfterlifeTextTheme.titleSmall.copyWith(
                            color: AfterlifeColors.neonPink,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _frases[_currentIndex],
                          textAlign: TextAlign.center,
                          style: AfterlifeTextTheme.headlineMedium.copyWith(
                            fontSize: 22,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón siguiente
              AfterButton(
                label: 'SIGUIENTE',
                color: AfterlifeColors.neonPink,
                onPressed: _nextFrase,
              ),
              const SizedBox(height: 16),
              Text(
                "Si lo has hecho, ¡aprieta tu botón!",
                style: AfterlifeTextTheme.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    // Ordenar jugadores por número de puntos (mayor a menor)
    final sorted = List<Map<String, dynamic>>.from(_players)
      ..sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RESUMEN', style: AfterlifeTextTheme.headlineMedium),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: AfterlifeColors.neonOrange),
              const SizedBox(height: 20),
              Text(
                '🏆 GANADOR 🏆',
                style: TextStyle(color: AfterlifeColors.neonOrange, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                sorted[0]['name'],
                style: AfterlifeTextTheme.headlineMedium.copyWith(
                  color: AfterlifeColors.neonOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${sorted[0]['points']} puntos',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'CLASIFICACIÓN FINAL',
                style: TextStyle(color: AfterlifeColors.neonPink, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ...sorted.map((player) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player['name'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${player['points']} ⭐',
                        style: const TextStyle(color: AfterlifeColors.neonOrange),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
              AfterButton(
                label: 'JUGAR DE NUEVO',
                color: AfterlifeColors.electricLilac,
                onPressed: _resetGame,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'VOLVER',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

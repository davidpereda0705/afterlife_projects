import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

class YoNuncaGame extends StatefulWidget {
  const YoNuncaGame({super.key});

  @override
  State<YoNuncaGame> createState() => _YoNuncaGameState();
}

class _YoNuncaGameState extends State<YoNuncaGame> {
  // Jugadores de ejemplo (nombre, iniciales, contador de bebidas)
  List<Map<String, dynamic>> _players = [
    {'name': 'Carlos', 'initials': 'CR', 'drinks': 0},
    {'name': 'Ana', 'initials': 'AN', 'drinks': 0},
    {'name': 'María', 'initials': 'MJ', 'drinks': 0},
    {'name': 'Luis', 'initials': 'LP', 'drinks': 0},
  ];

  // Frases (puedes usar las que ya tienes)
  List<String> _frases = [
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
    _frases.shuffle(); // Mezclar al inicio
  }

  void _addDrink(int index) {
    setState(() {
      _players[index]['drinks'] = (_players[index]['drinks'] as int) + 1;
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
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
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
                backgroundColor: Colors.white10,
                color: const Color(0xFFEC4899),
              ),
              const SizedBox(height: 8),
              Text(
                'Frase ${_currentIndex + 1}/${_frases.length}',
                style: AfterlifeTextTheme.bodySmall.copyWith(color: Colors.white54),
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
                              color: const Color(0xFFEC4899).withOpacity(0.2),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${player['drinks']} 🍻',
                              style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.local_drink, color: Color(0xFFEC4899)),
                            onPressed: () => _addDrink(index),
                            tooltip: 'Añadir bebida',
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
                          color: const Color(0xFFEC4899),
                          size: 50,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "YO NUNCA NUNCA...",
                          style: AfterlifeTextTheme.titleSmall.copyWith(
                            color: const Color(0xFFEC4899),
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
                color: const Color(0xFFEC4899),
                onPressed: _nextFrase,
              ),
              const SizedBox(height: 16),
              Text(
                "Si lo has hecho, ¡aprieta tu botón de bebida!",
                style: AfterlifeTextTheme.bodySmall.copyWith(
                  color: AfterlifeColors.textSecondary,
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
    // Ordenar jugadores por número de bebidas (mayor a menor)
    final sorted = List<Map<String, dynamic>>.from(_players)
      ..sort((a, b) => (b['drinks'] as int).compareTo(a['drinks'] as int));

    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AfterlifeColors.textPrimary),
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
              const Icon(Icons.emoji_events, size: 80, color: Color(0xFFF59E0B)),
              const SizedBox(height: 20),
              Text(
                '🏆 GANADOR 🏆',
                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                sorted[0]['name'],
                style: AfterlifeTextTheme.headlineMedium.copyWith(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${sorted[0]['drinks']} bebidas',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'CLASIFICACIÓN FINAL',
                style: TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ...sorted.map((player) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(player['name'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text('${player['drinks']} 🍻', style: const TextStyle(color: Color(0xFFF59E0B))),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 40),
              AfterButton(
                label: 'JUGAR DE NUEVO',
                color: AfterlifeColors.electricLilac,
                onPressed: _resetGame,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('VOLVER', style: TextStyle(color: AfterlifeColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/reto_rapido.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

class RetoRapidoGame extends StatefulWidget {
  final List<Map<String, dynamic>>? players; // Opcional: lista de jugadores {name, initials}
  const RetoRapidoGame({super.key, this.players});

  @override
  State<RetoRapidoGame> createState() => _RetoRapidoGameState();
}

class _RetoRapidoGameState extends State<RetoRapidoGame> {
  late List<Map<String, dynamic>> _players;
  late List<Map<String, dynamic>> _turnQueue; // Lista de jugadores en orden de turno (ya mezclada)
  int _currentTurnIndex = 0; // Índice dentro de _turnQueue
  late List<String> _retos;
  int _currentRetoIndex = 0;
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _challengeCompleted = false;
  bool _gameFinished = false;

  @override
  void initState() {
    super.initState();
    // Inicializar jugadores
    if (widget.players != null && widget.players!.isNotEmpty) {
      _players = widget.players!.map((p) {
        return {
          'name': p['name'],
          'initials': p['initials'],
          'completed': 0,
          'failed': 0,
        };
      }).toList();
    } else {
      // Datos de ejemplo si no se pasan
      _players = [
        {'name': 'Carlos', 'initials': 'CR', 'completed': 0, 'failed': 0},
        {'name': 'Ana', 'initials': 'AN', 'completed': 0, 'failed': 0},
        {'name': 'María', 'initials': 'MJ', 'completed': 0, 'failed': 0},
        {'name': 'Luis', 'initials': 'LP', 'completed': 0, 'failed': 0},
      ];
    }
    _retos = [
      "Haz 'twerk' contra la pared sin música durante 20 segundos.",
      "Intenta lamerte el codo mientras los demás te graban.",
      "Haz la croqueta por el suelo de una punta a otra de la sala.",
      "Imita a un gorila enfadado buscando comida por toda la habitación.",
      "Haz 15 sentadillas gritando '¡SOY UN POTRO SALVAJE!'",
      "Pide una pizza imaginaria usando un zapato como teléfono.",
      "Mantén el equilibrio sobre un solo pie y haz sonidos de helicóptero.",
      "Intenta hacer el 'Moonwalk' de Michael Jackson.",
      "Haz un baile interpretativo de una tostadora quemándose.",
      "Bebe un chupito sin usar las manos, solo con la boca.",
      "Llama a alguien y dile 'Ya he enterrado el paquete' y cuelga.",
      "Deja que el grupo escriba una storie en tu Instagram por 1 hora.",
      "Envía un emoji de 'popó' a tu quinto contacto de WhatsApp.",
      "Recrea un baile viral de TikTok ahora mismo sin música.",
      "Muestra la foto más vergonzosa de tu galería.",
      "Lee en voz alta los últimos 3 mensajes recibidos por WhatsApp.",
      "Envía un audio diciendo 'Te quiero' a quien el grupo elija.",
      "Habla con acento extranjero los próximos 2 minutos.",
      "Declara tu amor eterno a una botella vacía con lágrimas.",
      "Imita a alguien de la sala hasta que lo adivinen.",
      "Canta un reggaetón como si fuera una ópera.",
      "Pide permiso a una silla para sentarte en el suelo.",
      "Intenta convencer a la pared de que te preste 50 euros.",
      "Nombra 10 marcas de alcohol en menos de 15 segundos.",
      "Narra lo que hace un amigo como si fueras un comentarista deportivo.",
      "Ponte un calcetín en la oreja hasta que acabe la ronda.",
      "Huele el zapato de tu derecha y descríbelo como un sumiller.",
      "Déjate maquillar por alguien y no te lo quites en toda la noche.",
      "Grita por la ventana '¡VALENCIA, ESTOY DISPONIBLE!'",
      "Haz un desfile de modelos usando una manta como capa de gala."
    ];
    _retos.shuffle();

    // Inicializar la cola de turnos mezclada aleatoriamente
    _shuffleTurnQueue();
  }

  void _shuffleTurnQueue() {
    // Creamos una copia de la lista de jugadores y la mezclamos
    List<Map<String, dynamic>> shuffled = List.from(_players);
    shuffled.shuffle();
    _turnQueue = shuffled;
    _currentTurnIndex = 0;
  }

  Map<String, dynamic> get _currentPlayer => _turnQueue[_currentTurnIndex];

  void _advanceTurn() {
    // Avanzar al siguiente jugador en la cola
    if (_currentTurnIndex < _turnQueue.length - 1) {
      _currentTurnIndex++;
    } else {
      // Se acabó la ronda: mezclar de nuevo y empezar otra
      _shuffleTurnQueue();
    }
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    _timer?.cancel();
    setState(() {
      _secondsLeft = 30;
      _isTimerRunning = true;
      _challengeCompleted = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        setState(() => _isTimerRunning = false);
        _addResult(false);
      }
    });
  }

  void _completeChallenge() {
    if (!_isTimerRunning || _challengeCompleted) return;
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _challengeCompleted = true;
    });
    _addResult(true);
  }

  void _addResult(bool completed) {
    setState(() {
      if (completed) {
        _currentPlayer['completed']++;
      } else {
        _currentPlayer['failed']++;
      }
    });
    // Mostrar feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(completed ? '✅ ¡Reto completado!' : '❌ Tiempo agotado... fallo'),
        backgroundColor: completed ? AfterlifeColors.acidGreen : Colors.redAccent,
        duration: const Duration(milliseconds: 800),
      ),
    );
    _nextReto();
  }

  void _nextReto() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _secondsLeft = 30;
      _challengeCompleted = false;
      if (_currentRetoIndex < _retos.length - 1) {
        _currentRetoIndex++;
      } else {
        // Fin del juego (se han mostrado todos los retos)
        _gameFinished = true;
        return;
      }
      // Avanzar al siguiente jugador
      _advanceTurn();
    });
  }

  void _resetGame() {
    setState(() {
      for (var p in _players) {
        p['completed'] = 0;
        p['failed'] = 0;
      }
      _retos.shuffle();
      _currentRetoIndex = 0;
      _shuffleTurnQueue();
      _isTimerRunning = false;
      _secondsLeft = 30;
      _challengeCompleted = false;
      _gameFinished = false;
    });
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameFinished) {
      return _buildResultsScreen();
    }

    final currentPlayer = _currentPlayer;

    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: Text('RETO RÁPIDO', style: AfterlifeTextTheme.headlineMedium.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AfterlifeColors.electricLilacGradient),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Panel de turno actual
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎲 TURNO DE',
                      style: TextStyle(color: Color(0xFFEC4899), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPlayer['name'],
                      style: AfterlifeTextTheme.headlineMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentPlayer['completed']} ✅ / ${currentPlayer['failed']} ❌',
                      style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Indicador circular
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _secondsLeft / 30,
                      strokeWidth: 8,
                      color: _secondsLeft <= 5 ? Colors.redAccent : const Color(0xFF06B6D4),
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_secondsLeft',
                        style: AfterlifeTextTheme.headlineLarge.copyWith(
                          fontSize: 48,
                          color: _secondsLeft <= 5 ? Colors.redAccent : Colors.white,
                        ),
                      ),
                      Text("SEG", style: AfterlifeTextTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tarjeta del reto
              Expanded(
                child: AfterlifeCard(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFF06B6D4), size: 40),
                        const SizedBox(height: 20),
                        Text(
                          _retos[_currentRetoIndex],
                          textAlign: TextAlign.center,
                          style: AfterlifeTextTheme.titleLarge.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isTimerRunning && !_gameFinished)
                    AfterButton(
                      label: '¡DALE!',
                      color: const Color(0xFF06B6D4),
                      onPressed: _startTimer,
                    ),
                  if (_isTimerRunning)
                    AfterButton(
                      label: 'COMPLETADO',
                      color: AfterlifeColors.acidGreen,
                      onPressed: _completeChallenge,
                    ),
                  if ((!_isTimerRunning && _secondsLeft < 30) || _gameFinished)
                    AfterButton(
                      label: 'SIGUIENTE',
                      color: AfterlifeColors.electricPurple,
                      onPressed: _nextReto,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Pulsa COMPLETADO si has superado el reto a tiempo',
                style: AfterlifeTextTheme.bodySmall.copyWith(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    // Ordenar por número de retos completados (mayor a menor)
    final sorted = List<Map<String, dynamic>>.from(_players)
      ..sort((a, b) => (b['completed'] ?? 0).compareTo(a['completed'] ?? 0));

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
                '${sorted[0]['completed']} retos completados',
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
                      Text('${player['completed']} ✅ / ${player['failed']} ❌',
                          style: const TextStyle(color: Color(0xFFF59E0B))),
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
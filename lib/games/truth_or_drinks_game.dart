import 'dart:math';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

class TruthOrDrinkGame extends StatefulWidget {
  const TruthOrDrinkGame({super.key});

  @override
  State<TruthOrDrinkGame> createState() => _TruthOrDrinkGameState();
}

class _TruthOrDrinkGameState extends State<TruthOrDrinkGame> {
  // Jugadores
  final List<String> _players = ["Alex", "Marta", "Carlos", "Lucía"];
  
  // Mapa para llevar el castigo individual de cada jugador
  final Map<String, int> _playerPenalties = {
    "Alex": 1,
    "Marta": 1,
    "Carlos": 1,
    "Lucía": 1,
  };

  int _currentPlayerIndex = 0;

  // Pregunta actual
  String _currentQuestion = "Pulsa empezar para una pregunta 🔥";

  int _questionIndex = 0;

  String get _currentPlayer => _players[_currentPlayerIndex];
  
  // Obtener los tragos actuales del jugador
  int get _currentPenalty => _playerPenalties[_currentPlayer] ?? 1;

  final List<String> _spicyQuestions = [
    // Nivel 1 - Calentando motores 🔥
    "¿Cuál es la parte del cuerpo que más te excita de alguien?",
    "¿Prefieres sexo con luces encendidas o apagadas?",
    "¿Cuál fue tu mejor orgasmo y con quién?",
    "¿Te gusta más hacerlo en la cama o en lugares prohibidos?",
    "¿Qué es lo más guarro que te han dicho al oído y te encantó?",
    "¿Con qué celebrity te irías a la cama sin pensarlo?",
    "¿Te gusta más oír gemidos o que te hablen sucio durante el sexo?",

    // Nivel 2 - Subiendo la temperatura 🥵
    "¿Alguna vez te has grabado teniendo sexo o masturbándote?",
    "¿Cuál es la cosa más atrevida que has hecho en público?",
    "¿Te correrías delante de una cámara si te pagaran bien?",
    "¿Has tenido sexo con alguien de este grupo? (sí o no y con quién)",
    "¿Qué posición del Kamasutra te mueres por probar?",
    "¿Te excita más la sumisión o la dominación?",
    "¿Has usado juguetes sexuales? ¿Cuál es tu favorito?",

    // Nivel 3 - Sin censura 🍑
    "¿Alguna vez te ha gustado el sexo duro con dolor incluido?",
    "¿Cuál ha sido tu trío soñado? (di nombres reales o famosos)",
    "¿Qué parte de tu cuerpo crees que es la más sexual?",
    "¿Prefieres sexo rápido y salvaje o lento y romántico?",
    "¿Te irías de vacaciones solo para follar sin parar?",
    "¿Has tenido sexo virtual con alguien por videollamada?",
    "¿Qué fetiche tienes y no has contado nunca?",

    // Nivel 4 - Locura total 🔞
    "¿Has follado en el coche? ¿Dónde fue el sitio más arriesgado?",
    "¿Te harías un trío con dos personas de esta sala? ¿Quiénes?",
    "¿Qué es lo más guarro que has chupado de alguien?",
    "¿Te ha gustado alguna vez que te amarren o amarrar a alguien?",
    "¿Has tenido sexo con alguien del trabajo o de tu familia?",
    "¿Prefieres que te coman a ti o comer tú?",
    "¿Alguna vez te ha excitado ver a alguien durmiendo?",

    // Nivel 5 - Ya no hay límites 💦
    "¿Te correrías en la boca de alguien aquí presente? ¿De quién?",
    "¿Qué es lo más pervertido que harías por un millón de euros?",
    "¿Te ha excitado alguna vez tu propio hermano/primo/hermana?",
    "¿Has espiado a alguien desnudándose o te gustaría hacerlo?",
    "¿Follarías con alguien a cambio de salvar la vida de un ser querido?",
    "¿Cuál es la mayor depravación sexual que has imaginado?",
    "¿Te gustaría ser parte de una orgía? ¿Con quién de aquí?",
  ];

  void _nextQuestion() {
    setState(() {
      _currentQuestion = _spicyQuestions[_questionIndex];

      _questionIndex++;

      if (_questionIndex >= _spicyQuestions.length) {
        _questionIndex = _spicyQuestions.length - 1;
      }
    });
  }

  void _answered() {
    setState(() {
      // Solo reiniciamos el castigo del jugador actual cuando RESPONDE
      _playerPenalties[_currentPlayer] = 1;

      _currentPlayerIndex++;

      if (_currentPlayerIndex >= _players.length) {
        _currentPlayerIndex = 0;
      }
    });

    _nextQuestion();
  }

  void _drinkPenalty() {
    final player = _currentPlayer;
    final currentPenalty = _currentPenalty;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$player bebe $currentPenalty tragos 🍻"),
        backgroundColor: AfterlifeColors.neonPink,
      ),
    );

    setState(() {
      // INCREMENTAMOS el castigo de ESTE jugador (no se reinicia)
      _playerPenalties[player] = currentPenalty + 1;

      _currentPlayerIndex++;

      if (_currentPlayerIndex >= _players.length) {
        _currentPlayerIndex = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,

      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        title: const Text(
          "Verdad o Bebida 🔥",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AfterlifeCard(
            child: Column(
              children: [
                Text(
                  "Turno de",
                  style: TextStyle(
                    color: AfterlifeColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _currentPlayer.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                // Mostrar los tragos acumulados del jugador actual
                const SizedBox(height: 4),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AfterlifeColors.neonPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AfterlifeColors.neonPink.withOpacity(0.5)),
                  ),
                  child: Text(
                    "🍻 $_currentPenalty trago${_currentPenalty != 1 ? 's' : ''} acumulado${_currentPenalty != 1 ? 's' : ''}",
                    style: TextStyle(
                      color: AfterlifeColors.neonPink,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          AfterlifeCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 40,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _currentQuestion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: AfterButton(
                  label: "RESPONDER",
                  color: AfterlifeColors.cyanBlue,
                  onPressed: _answered,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: AfterButton(
                  label: "BEBER ($_currentPenalty)",
                  color: AfterlifeColors.acidGreen,
                  onPressed: _drinkPenalty,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              "Si no respondes, tus tragos acumulados aumentan 🍻",
              style: TextStyle(
                color: AfterlifeColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Mostrar el resumen de tragos de todos los jugadores
          AfterlifeCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ESTADO DE TRAGOS 🍻",
                    style: TextStyle(
                      color: AfterlifeColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._players.map((player) {
                    final penalty = _playerPenalties[player] ?? 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            player,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: player == _currentPlayer 
                                  ? AfterlifeColors.acidGreen.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: player == _currentPlayer
                                    ? AfterlifeColors.acidGreen
                                    : AfterlifeColors.textSecondary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              "$penalty trago${penalty != 1 ? 's' : ''}",
                              style: TextStyle(
                                color: player == _currentPlayer
                                    ? AfterlifeColors.acidGreen
                                    : AfterlifeColors.textSecondary,
                                fontWeight: player == _currentPlayer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
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
  // ===== NIVEL 1 - CALENTANDO MOTORES (20 preguntas) 🔥 =====
  "¿Cuál es la cualidad física que más te atrae en alguien?",
  "¿Prefieres las citas en lugares tranquilos o en sitios con mucha gente?",
  "¿Cuál fue tu mejor cita y qué la hizo especial?",
  "¿Te gusta más planear las citas o que te sorprendan?",
  "¿Qué es lo más romántico que te han dicho?",
  "¿Con qué celebrity te irías a cenar sin pensarlo?",
  "¿Te gusta más que te escriban mensajes dulces o que te llamen por teléfono?",
  "¿Qué tipo de ropa te parece más atractiva en los demás?",
  "¿Prefieres una sonrisa bonita o una mirada profunda?",
  "¿Has tenido alguna vez un sueño muy bonito con alguien conocido?",
  "¿Qué es lo primero que harías si te quedaras a solas con tu crush? (versión cute)",
  "¿Te consideras más de dar sorpresas o de recibirlas?",
  "¿Cuál es tu mejor cualidad en una relación?",
  "¿Prefieres los besos en la frente o en los labios?",
  "¿Qué te parece más atractivo: la inteligencia o el sentido del humor?",
  "¿Alguna vez te has sonrojado en público por algo que te dijeron?",
  "¿Qué celebrity te parece más atractiva y por qué?",
  "¿Prefieres las salidas por la mañana o por la noche?",
  "¿Te gusta más el café caliente o el helado después de una cita?",
  "¿Qué piensas de pedirle el número a alguien en la primera cita?",

  // ===== NIVEL 2 - SUBIENDO EL INTERÉS (20 preguntas) 🥵 =====
  "¿Alguna vez has tenido una anécdota vergonzosa con una cita? Cuéntala.",
  "¿Cuál es la cosa más atrevida que has hecho para conquistar a alguien?",
  "¿Harías un viaje improvisado con alguien que acabas de conocer?",
  "¿Has tenido una cita con alguien de este grupo? (sí o no y con quién, si quieres)",
  "¿Qué plan de cita te mueres por hacer y nunca has hecho?",
  "¿Te gusta más conquistar o dejarte conquistar?",
  "¿Has usado alguna vez alguna app de citas? ¿Qué tal te fue?",
  "¿Cuál ha sido el sitio más original donde has tenido una cita?",
  "¿Te gusta más tener citas en casa o en sitios públicos?",
  "¿Has tenido alguna videollamada para conocerte con alguien antes de quedar?",
  "¿Qué es lo más divertido que has hecho con tu ex?",
  "¿Prefieres citas rápidas o tardes enteras juntos?",
  "¿Te gusta que te hagan regalos inesperados?",
  "¿Has usado alguna vez un juego de preguntas como este en una cita?",
  "¿Qué opinas de las citas a ciegas? ¿Te animarías?",
  "¿Te gusta más dar regalos o recibirlos?",
  "¿Has hecho alguna vez un baile o algo especial para impresionar a alguien?",
  "¿Prefieres hacer planes con música o en silencio?",
  "¿Qué es lo más atrevido que harías en una primera cita?",
  "¿Te gustaría probar una cita de aventura (tirolina, escalada, etc.) algún día?",

  // ===== NIVEL 3 - DESVELANDO SECRETOS (20 preguntas) 🍑 =====
  "¿Alguna vez te has enamorado de alguien que no debías?",
  "¿Cuál ha sido tu sueño romántico más loco? (con nombres reales o famosos)",
  "¿Qué parte de tu personalidad crees que es la más atractiva?",
  "¿Prefieres que te conquisten con detalles o con palabras bonitas?",
  "¿Te irías de vacaciones con alguien que conocieras hace un mes?",
  "¿Has tenido una relación a distancia? ¿Cómo la llevaste?",
  "¿Qué fetiche inocente tienes? (ej. que te hagan cosquillas, que te arreglen el pelo…)",
  "¿Te gustaría tener una cita sorpresa en tu lugar de trabajo?",
  "¿Has tenido una cita con alguien mientras otra persona os acompañaba?",
  "¿Cuál es la cosa más vergonzosa que has hecho por amor?",
  "¿Te excita la idea de ligar con alguien que sabes que tiene pareja? (sin malicia, solo la adrenalina)",
  "¿Has tenido una relación con tu mejor amigo/a?",
  "¿Prefieres las citas en la playa de día o de noche?",
  "¿Qué es lo más loco que harías por una persona que te gusta mucho?",
  "¿Te gustaría aprender a bailar para sorprender a alguien?",
  "¿Has tenido alguna vez una cita en el cine?",
  "¿Qué piensas de las apps que te permiten compartir tu ubicación con tu pareja?",
  "¿Te grabarías cantando para enviárselo a alguien que te gusta?",
  "¿Has tenido una cita con alguien que conociste el mismo día?",
  "¿Qué es lo más dulce que has chupado o te han chupado? (chuparse un dedo con nata, por ejemplo)",

  // ===== NIVEL 4 - ATREVIMIENTOS (20 preguntas) 🔞 =====
  "¿Has tenido una cita en el coche? ¿Dónde fue el sitio más inesperado?",
  "¿Te harías un viaje de tres con dos personas de esta sala? ¿Quiénes?",
  "¿Qué es lo más divertido que has bailado con alguien?",
  "¿Te ha gustado alguna vez que te hagan cosquillas o hacerlas tú?",
  "¿Has tenido una relación con alguien del trabajo?",
  "¿Prefieres que te den de comer o dar tú de comer a alguien?",
  "¿Alguna vez te ha dado curiosidad ver cómo duerme alguien?",
  "¿Cuál es el lugar más inusual donde has tenido una cita?",
  "¿Has tenido dos citas en el mismo día?",
  "¿Te gustaría tener una cita en un lugar con riesgo de ser interrumpidos?",
  "¿Has usado alguna vez algún juego de mesa para ligar?",
  "¿Qué es lo más atrevido que te han pedido en una cita?",
  "¿Has tenido una cita con alguien mucho mayor que tú?",
  "¿Te gusta el baile con movimientos divertidos?",
  "¿Has tenido una cita en casa de tus padres mientras ellos estaban?",
  "¿Qué es lo más extremo que harías por una cita con tu celebrity favorita?",
  "¿Has tenido una cita con tu jefe o compañero de trabajo?",
  "¿Te gustan las citas en grupo? ¿Cuál es tu número ideal?",
  "¿Has tenido una cita en un probador de ropa? (solo para charlar, eh)",
  "¿Qué es lo más divertido que has dicho durante una cita?",

  // ===== NIVEL 5 - YA NO HAY LÍMITES (20 preguntas) 💦 =====
  "¿Confesarías tu crush secreto a alguien aquí presente? ¿A quién?",
  "¿Qué es lo más atrevido que harías por un millón de euros? (sin nada ilegal ni inmoral)",
  "¿Te ha gustado alguna vez alguien del grupo de amigos de tu hermano/hermana?",
  "¿Has espiado a alguien en una situación divertida o te gustaría hacerlo?",
  "¿Cantarías en público a cambio de salvar la vida de un ser querido?",
  "¿Cuál es la mayor locura romántica que has imaginado?",
  "¿Te gustaría formar parte de un concurso de parejas? ¿Con quién de aquí?",
  "¿Has tenido una cita en un lugar insólito como un cementerio o una biblioteca?",
  "¿Qué es lo más extremo que harías por una cita inolvidable?",
  "¿Te excita la idea de una cita prohibida? (sin llegar a lo ilegal)",
  "¿Has tenido una cita con alguien mientras otra persona os miraba sin saberlo?",
  "¿Te gustaría ser mayordomo por un día de alguien de este grupo?",
  "¿Has hecho algún vídeo divertido con una cita que pueda hacerse viral?",
  "¿Qué es lo más humillante (en tono divertido) que te gustaría probar en una cita? (ej. disfraz)",
  "¿Has tenido una cita con un menor (cuando eras menor también)? (versión inocente: cita en el parque)",
  "¿Te gustaría tener una cita en un lugar histórico como una iglesia o museo?",
  "¿Has tenido una cita con tu mascota de por medio? (paseo con perro)",
  "¿Qué es lo más aventurero que te gusta en una cita?",
  "¿Te lanzarías a declararte a alguien sin protección contra el rechazo?",
  "¿Has tenido una cita con alguien que sabías que tenía fama de rompecorazones?",
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
    
    // SNACKBAR ELIMINADO - ahora solo se ve en el contador

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
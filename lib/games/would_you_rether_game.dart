// lib/screens/would_you_rather_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

class WouldYouRatherGame extends StatefulWidget {
  final List<Map<String, dynamic>>? players;
  const WouldYouRatherGame({super.key, this.players});

  @override
  State<WouldYouRatherGame> createState() => _WouldYouRatherGameState();
}

class _WouldYouRatherGameState extends State<WouldYouRatherGame> {
  late List<String> _players;
  
  // Categoría seleccionada
  final String _selectedCategory = 'explosivo';
  
  // Estado del juego
  bool _gameStarted = false;
  bool _votingInProgress = false;
  bool _showResults = false;
  int _currentVoterIndex = 0;
  
  // Dilema actual
  String _currentOptionA = 'Toca un botón';
  String _currentOptionB = 'para empezar';
  
  // Votos (anónimos, solo contadores)
  int _votesA = 0;
  int _votesB = 0;
  List<bool> _hasVoted = [];
  
  // Resultados
  List<String> _losers = [];

  // Dilemas PICANTES Y EXPLÍCITOS
  final Map<String, List<Map<String, String>>> _dilemmas = {
    'explosivo': [
        {'a': '¿Prefieres una cena romántica a la luz de las velas?', 'b': '¿Prefieres una cita de aventura (tirolina, escalada)?'},
    {'a': '¿Prefieres pasar la noche viendo películas en casa?', 'b': '¿Prefieres salir a bailar hasta tarde?'},
    {'a': '¿Prefieres que te hagan un masaje relajante?', 'b': '¿Prefieres dar un masaje relajante?'},
    {'a': '¿Prefieres un beso en la frente?', 'b': '¿Prefieres un beso en los labios?'},
    {'a': '¿Prefieres una declaración de amor pública y sorprendente?', 'b': '¿Prefieres una declaración íntima y privada?'},
    {'a': '¿Prefieres vivir una historia de amor de película?', 'b': '¿Prefieres una historia de amor de libro?'},
    {'a': '¿Prefieres salir con alguien 10 años mayor?', 'b': '¿Prefieres salir con alguien 10 años menor?'},
    {'a': '¿Prefieres una noche con tu celebrity favorita (solo conversar)?', 'b': '¿Prefieres una noche con alguien de esta sala?'},
    {'a': '¿Prefieres una relación rápida e intensa?', 'b': '¿Prefieres una relación lenta y profunda?'},
    {'a': '¿Prefieres que te graben haciendo el ridículo?', 'b': '¿Prefieres grabar tú a otros haciendo el ridículo?'},
    {'a': '¿Prefieres usar juegos de mesa para ligar?', 'b': '¿Prefieres ligar solo con la conversación?'},
    {'a': '¿Prefieres hacer un baile sorpresa?', 'b': '¿Prefieres que te hagan un baile sorpresa?'},
    {'a': '¿Prefieres una cita en el trabajo (con discreción)?', 'b': '¿Prefieres una cita en el baño de un bar (solo charla)?'},
    {'a': '¿Prefieres un detalle romántico hecho a mano?', 'b': '¿Prefieres un regalo caro y comprado?'},
    {'a': '¿Prefieres que te aten… con un compromiso?', 'b': '¿Prefieres atar… con un compromiso a alguien?'},
    {'a': '¿Prefieres reencontrarte con tu ex en plan amistad?', 'b': '¿Prefieres quedar con tu mejor amigo en plan romántico?'},
    {'a': '¿Prefieres una noche de pasión con un desconocido (solo pasión por la conversación)?', 'b': '¿Prefieres una noche con alguien conocido pero fuera de tu liga?'},
    {'a': '¿Prefieres confesar tu crush en público?', 'b': '¿Prefieres confesar tu crush en privado?'},
    {'a': '¿Prefieres una cita en un lugar público con riesgo de ser vistos?', 'b': '¿Prefieres una cita en un lugar privado pero aburrido?'},
    {'a': '¿Prefieres una persona dominante en la relación?', 'b': '¿Prefieres una persona sumisa en la relación?'},
    {'a': '¿Prefieres que te muerdan… una manzana?', 'b': '¿Prefieres morder… una manzana?'},
    {'a': '¿Prefieres hacer una videollamada romántica?', 'b': '¿Prefieres enviar cartas de amor digitales?'},
    {'a': '¿Prefieres tener una cita con tu jefe?', 'b': '¿Prefieres tener una cita con tu empleado?'},
    {'a': '¿Prefieres salir con alguien casado (y divorciándose)?', 'b': '¿Prefieres salir con un cura (que ha dejado los hábitos)?'},
    {'a': '¿Prefieres que te conquiste un desconocido?', 'b': '¿Prefieres conquistar a un desconocido?'},
    {'a': '¿Prefieres una relación apasionada con discusiones?', 'b': '¿Prefieres una relación tranquila con caricias?'},
    {'a': '¿Prefieres un trío de amigos?', 'b': '¿Prefieres un trío de famosos?'},
    {'a': '¿Prefieres una cita en una iglesia (de turismo)?', 'b': '¿Prefieres una cita en un cementerio (de turismo)?'},
    {'a': '¿Prefieres chupar un polo de fresa?', 'b': '¿Prefieres chupar un polo de limón?'},
    {'a': '¿Prefieres que te hagan una fiesta sorpresa?', 'b': '¿Prefieres hacer una fiesta sorpresa?'},
    {'a': '¿Prefieres salir con tu hermanastra (en plan broma)?', 'b': '¿Prefieres salir con tu profesor (años después)?'},
    {'a': '¿Prefieres salir con alguien que tiene mala fama?', 'b': '¿Prefieres salir con alguien que no te gusta físicamente pero es genial?'},
    {'a': '¿Prefieres cuidar de un animal?', 'b': '¿Prefieres cuidar de un niño (como canguro)?'},
    {'a': '¿Prefieres ser el líder de un proyecto?', 'b': '¿Prefieres ser el ayudante de un proyecto?'},
    {'a': '¿Prefieres que te tomen el pelo cariñosamente?', 'b': '¿Prefieres tomar el pelo cariñosamente?'},
    {'a': '¿Prefieres una orgía de risas con 10 personas?', 'b': '¿Prefieres un trío de risas con 2 celebrities?'},
    {'a': '¿Prefieres que te graben cantando mal?', 'b': '¿Prefieres grabar a alguien cantando mal?'},
    {'a': '¿Prefieres una cita en el probador de Zara (solo para tomar fotos)?', 'b': '¿Prefieres una cita en el baño del Mercadona (para comprar snacks)?'},
    {'a': '¿Prefieres una cita con tu mejor amigo del mismo sexo?', 'b': '¿Prefieres una cita con tu peor enemigo del sexo opuesto?'},
    {'a': '¿Prefieres que te den un masaje en todo el cuerpo?', 'b': '¿Prefieres dar un masaje en todo el cuerpo?'},
    {'a': '¿Prefieres un coche grande?', 'b': '¿Prefieres una casa grande?'},
    {'a': '¿Prefieres confesar un secreto dentro del grupo?', 'b': '¿Prefieres confesar un secreto fuera del grupo?'},
    {'a': '¿Prefieres una relación con protección (emocional)?', 'b': '¿Prefieres una relación sin protección asumiendo riesgos?'},
    {'a': '¿Prefieres una cita con alguien de esta sala?', 'b': '¿Prefieres una cita con un famoso feo pero rico?'},
    {'a': '¿Prefieres que te conquiste un desconocido por la calle?', 'b': '¿Prefieres conquistar a un desconocido en tu casa?'},
    {'a': '¿Prefieres una quedada en grupo con amigos?', 'b': '¿Prefieres una quedada en grupo con desconocidos?'},
    {'a': '¿Prefieres chupar un chupa-chups?', 'b': '¿Prefieres que te chupen un chupa-chups?'},
    {'a': '¿Prefieres que te hagan una cita a ciegas?', 'b': '¿Prefieres hacer una cita a ciegas?'},
    ],
  };

  // Colores para la categoría
  final Map<String, Color> _categoryColors = {
    'explosivo': AfterlifeColors.neonPink,
  };

  @override
  void initState() {
    super.initState();
    if (widget.players != null && widget.players!.isNotEmpty) {
      _players = widget.players!.map((p) => p['name'] as String).toList();
    } else {
      _players = ["Alex", "Marta", "Carlos", "Lucía"];
    }
    _resetVotingState();
  }

  void _resetVotingState() {
    _hasVoted = List.filled(_players.length, false);
    _votesA = 0;
    _votesB = 0;
    _currentVoterIndex = 0;
    _losers.clear();
  }

  // Obtener dilema aleatorio
  void _getRandomDilemma() {
    final categoryDilemmas = _dilemmas[_selectedCategory]!;
    final random = Random();
    final index = random.nextInt(categoryDilemmas.length);
    final dilemma = categoryDilemmas[index];
    
    setState(() {
      _currentOptionA = dilemma['a']!;
      _currentOptionB = dilemma['b']!;
      _gameStarted = true;
      _votingInProgress = true;
      _showResults = false;
      _resetVotingState();
    });
  }

  // Votar por opción A
  void _voteA() {
    if (!_votingInProgress) return;
    if (_hasVoted[_currentVoterIndex]) return;
    
    setState(() {
      _votesA++;
      _hasVoted[_currentVoterIndex] = true;
      _nextVoter();
    });
  }

  // Votar por opción B
  void _voteB() {
    if (!_votingInProgress) return;
    if (_hasVoted[_currentVoterIndex]) return;
    
    setState(() {
      _votesB++;
      _hasVoted[_currentVoterIndex] = true;
      _nextVoter();
    });
  }

  void _nextVoter() {
    int nextIndex = _currentVoterIndex + 1;
    while (nextIndex < _players.length && _hasVoted[nextIndex]) {
      nextIndex++;
    }
    
    if (nextIndex < _players.length) {
      _currentVoterIndex = nextIndex;
    } else {
      _showVotingResults();
    }
  }

  void _showVotingResults() {
    setState(() {
      _votingInProgress = false;
      _showResults = true;
      
      if (_votesA < _votesB) {
        _losers = ["Los que votaron OPCIÓN A"];
      } else if (_votesB < _votesA) {
        _losers = ["Los que votaron OPCIÓN B"];
      } else {
        _losers = ["TODOS"];
      }
    });
  }

  // Siguiente ronda
  void _nextRound() {
    _getRandomDilemma();
  }

  String _getCurrentVoter() {
    if (_currentVoterIndex < _players.length) {
      return _players[_currentVoterIndex];
    }
    return "???";
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor = _categoryColors[_selectedCategory]!;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '¿Qué prefieres?',
          style: AfterlifeTextTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabecera del modo
          AfterlifeCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.whatshot, color: AfterlifeColors.neonPink, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'MODO EXPLOSIVO',
                        style: TextStyle(
                          color: AfterlifeColors.neonPink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votación anónima por turnos. Pasa el móvil a cada persona.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tarjeta del dilema
          AfterlifeCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icono decorativo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.balance,
                      color: currentColor,
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Opción A
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AfterlifeColors.cyanBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AfterlifeColors.cyanBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _currentOptionA,
                          style: AfterlifeTextTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_showResults) ...[
                          const SizedBox(height: 8),
                          Text(
                            '$_votesA voto${_votesA != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: AfterlifeColors.cyanBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Separador "O"
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: currentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Opción B
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AfterlifeColors.neonPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AfterlifeColors.neonPink.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _currentOptionB,
                          style: AfterlifeTextTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_showResults) ...[
                          const SizedBox(height: 8),
                          Text(
                            '$_votesB voto${_votesB != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: AfterlifeColors.neonPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  if (!_gameStarted) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Pulsa EMPEZAR para la primera ronda',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Botones de votación
          if (_gameStarted && _votingInProgress) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AfterlifeColors.electricPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AfterlifeColors.electricPurple),
              ),
              child: Column(
                children: [
                  Text(
                    'TURNO DE:',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCurrentVoter().toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vota en privado, nadie más mira',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AfterButton(
                          label: 'OPCIÓN A',
                          color: AfterlifeColors.cyanBlue,
                          onPressed: _voteA,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AfterButton(
                          label: 'OPCIÓN B',
                          color: AfterlifeColors.neonPink,
                          onPressed: _voteB,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Progreso de votación
          if (_gameStarted && _votingInProgress) _buildVotingProgress(),
          
          // Resultados
          if (_showResults) _buildResultsCard(),
          
          const SizedBox(height: 20),
          
          // Botón para siguiente ronda
          if (_showResults)
            Center(
              child: AfterButton(
                label: 'SIGUIENTE RONDA',
                color: currentColor,
                onPressed: _nextRound,
              ),
            ),
          
          // Botón para empezar
          if (!_gameStarted)
            Center(
              child: AfterButton(
                label: 'EMPEZAR JUEGO',
                color: currentColor,
                onPressed: _getRandomDilemma,
              ),
            ),
        ],
      ),
    );
  }

  // Barra de progreso de votación
  Widget _buildVotingProgress() {
    final votedCount = _hasVoted.where((voted) => voted).length;
    final progress = votedCount / _players.length;
    
    return AfterlifeCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROGRESO',
                  style: TextStyle(
                    color: AfterlifeColors.electricLilac,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$votedCount/${_players.length}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              color: AfterlifeColors.acidGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de resultados
  Widget _buildResultsCard() {
    String resultado = '';
    Color colorResultado = AfterlifeColors.neonOrange;
    
    if (_votesA < _votesB) {
      resultado = 'PIERDE OPCIÓN A\nPierden los que votaron A';
    } else if (_votesB < _votesA) {
      resultado = 'PIERDE OPCIÓN B\nPierden los que votaron B';
    } else {
      resultado = 'EMPATE\nPIERDEN TODOS';
      colorResultado = AfterlifeColors.acidGreen;
    }
    
    return AfterlifeCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorResultado.withValues(alpha: 0.2),
              AfterlifeColors.electricPurple.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorResultado, width: 2),
        ),
        child: Column(
          children: [
            Text(
              'RESULTADOS',
              style: TextStyle(
                color: colorResultado,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'OPCIÓN A',
                      style: TextStyle(
                        color: AfterlifeColors.cyanBlue,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$_votesA',
                      style: TextStyle(
                        color: AfterlifeColors.cyanBlue,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  width: 2,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                ),
                Column(
                  children: [
                    Text(
                      'OPCIÓN B',
                      style: TextStyle(
                        color: AfterlifeColors.neonPink,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$_votesB',
                      style: TextStyle(
                        color: AfterlifeColors.neonPink,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorResultado.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                resultado,
                style: TextStyle(
                  color: colorResultado,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

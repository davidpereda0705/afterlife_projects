// lib/screens/would_you_rather_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

class WouldYouRatherGame extends StatefulWidget {
  const WouldYouRatherGame({super.key});

  @override
  State<WouldYouRatherGame> createState() => _WouldYouRatherGameState();
}

class _WouldYouRatherGameState extends State<WouldYouRatherGame> {
  // Jugadores fijos
  final List<String> _players = ["Alex", "Marta", "Carlos", "Lucía"];
  
  // Categoría seleccionada
  String _selectedCategory = 'explosivo';
  
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
      {'a': '¿Prefieres sexo con luces encendidas?', 'b': '¿Prefieres sexo a oscuras?'},
      {'a': '¿Prefieres hacer un trío?', 'b': '¿Prefieres una orgía?'},
      {'a': '¿Prefieres que te coman el culo?', 'b': '¿Prefieres comerle el culo a alguien?'},
      {'a': '¿Prefieres follar en la playa de día?', 'b': '¿Prefieres follar en el coche de noche?'},
      {'a': '¿Prefieres sexo oral?', 'b': '¿Prefieres penetración?'},
      {'a': '¿Prefieres hacerlo con alguien 10 años mayor?', 'b': '¿Prefieres hacerlo con alguien 10 años menor?'},
      {'a': '¿Prefieres una noche con tu celebrity favorita?', 'b': '¿Prefieres una noche con alguien de esta sala?'},
      {'a': '¿Prefieres sexo rápido y salvaje?', 'b': '¿Prefieres sexo lento y romántico?'},
      {'a': '¿Prefieres que te graben follando?', 'b': '¿Prefieres grabar tú a otros follando?'},
      {'a': '¿Prefieres usar juguetes sexuales?', 'b': '¿Prefieres sexo solo con cuerpos?'},
      {'a': '¿Prefieres hacer un striptease?', 'b': '¿Prefieres que te hagan un striptease?'},
      {'a': '¿Prefieres sexo en el trabajo?', 'b': '¿Prefieres sexo en el baño de un bar?'},
      {'a': '¿Prefieres una mamada?', 'b': '¿Prefieres un cunnilingus?'},
      {'a': '¿Prefieres que te aten?', 'b': '¿Prefieres atar a alguien?'},
      {'a': '¿Prefieres sexo con tu ex?', 'b': '¿Prefieres sexo con tu mejor amigo?'},
      {'a': '¿Prefieres una noche de pasión con desconocido?', 'b': '¿Prefieres una noche con alguien conocido pero fuera de tu liga?'},
      {'a': '¿Prefieres que te corran en la boca?', 'b': '¿Prefieres correrte en la boca de alguien?'},
      {'a': '¿Prefieres sexo anal?', 'b': '¿Prefieres sexo vaginal?'},
      {'a': '¿Prefieres follar en un lugar público con riesgo?', 'b': '¿Prefieres follar en un lugar privado pero aburrido?'},
      {'a': '¿Prefieres una dominatrix?', 'b': '¿Prefieres un sumiso?'},
      {'a': '¿Prefieres que te muerdan?', 'b': '¿Prefieres morder?'},
      {'a': '¿Prefieres hacer una videollamada erótica?', 'b': '¿Prefieres enviar nudes?'},
      {'a': '¿Prefieres tener sexo con tu jefe?', 'b': '¿Prefieres tener sexo con tu empleado?'},
      {'a': '¿Prefieres follar con alguien casado?', 'b': '¿Prefieres follar con un cura?'},
      {'a': '¿Prefieres que te folle un desconocido?', 'b': '¿Prefieres follar a un desconocido?'},
      {'a': '¿Prefieres sexo duro con azotes?', 'b': '¿Prefieres sexo suave con caricias?'},
      {'a': '¿Prefieres un trío H-M-H?', 'b': '¿Prefieres un trío M-H-M?'},
      {'a': '¿Prefieres follar en la iglesia?', 'b': '¿Prefieres follar en el cementerio?'},
      {'a': '¿Prefieres chupar un pezón?', 'b': '¿Prefieres chupar un glande?'},
      {'a': '¿Prefieres que te hagan un bukkake?', 'b': '¿Prefieres hacer un bukkake?'},
      {'a': '¿Prefieres follar con tu hermanastra?', 'b': '¿Prefieres follar con tu profesor?'},
      {'a': '¿Prefieres sexo con alguien que tiene ETS?', 'b': '¿Prefieres sexo con alguien que no te gusta?'},
      {'a': '¿Prefieres follar con un animal?', 'b': '¿Prefieres follar con un menor (siendo menor)?'},
      {'a': '¿Prefieres ser esclavo sexual?', 'b': '¿Prefieres tener un esclavo sexual?'},
      {'a': '¿Prefieres que te follen por detrás?', 'b': '¿Prefieres follar por detrás?'},
      {'a': '¿Prefieres una orgía con 10 personas?', 'b': '¿Prefieres un trío con 2 celebrities?'},
      {'a': '¿Prefieres que te graben masturbándote?', 'b': '¿Prefieres grabar a alguien masturbándose?'},
      {'a': '¿Prefieres follar en el probador de Zara?', 'b': '¿Prefieres follar en el baño del Mercadona?'},
      {'a': '¿Prefieres sexo con tu mejor amigo del mismo sexo?', 'b': '¿Prefieres sexo con tu peor enemigo del sexo opuesto?'},
      {'a': '¿Prefieres que te laman todo el cuerpo?', 'b': '¿Prefieres lamer todo el cuerpo de alguien?'},
      {'a': '¿Prefieres una polla grande?', 'b': '¿Prefieres un culo grande?'},
      {'a': '¿Prefieres correrte dentro?', 'b': '¿Prefieres correrte fuera?'},
      {'a': '¿Prefieres sexo con preservativo?', 'b': '¿Prefieres sexo sin preservativo asumiendo riesgos?'},
      {'a': '¿Prefieres follar con alguien de esta sala?', 'b': '¿Prefieres follar con un famoso feo pero rico?'},
      {'a': '¿Prefieres que te folle un desconocido por la calle?', 'b': '¿Prefieres follar a un desconocido en tu casa?'},
      {'a': '¿Prefieres sexo en grupo con amigos?', 'b': '¿Prefieres sexo en grupo con desconocidos?'},
      {'a': '¿Prefieres chupar un consolador?', 'b': '¿Prefieres que te chupen un consolador?'},
      {'a': '¿Prefieres que te follen con los ojos vendados?', 'b': '¿Prefieres follar con los ojos vendados?'},
    ],
  };

  // Colores para la categoría
  final Map<String, Color> _categoryColors = {
    'explosivo': AfterlifeColors.neonPink,
  };

  @override
  void initState() {
    super.initState();
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

  // Reiniciar juego
  void _resetGame() {
    setState(() {
      _gameStarted = false;
      _votingInProgress = false;
      _showResults = false;
      _resetVotingState();
      _currentOptionA = 'Toca un botón';
      _currentOptionB = 'para empezar';
    });
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
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AfterlifeColors.textPrimary),
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
                      color: AfterlifeColors.textSecondary,
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
                      color: currentColor.withOpacity(0.2),
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
                      color: AfterlifeColors.cyanBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AfterlifeColors.cyanBlue.withOpacity(0.3),
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
                      color: currentColor.withOpacity(0.2),
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
                      color: AfterlifeColors.neonPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AfterlifeColors.neonPink.withOpacity(0.3),
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
                        color: AfterlifeColors.textSecondary,
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
                color: AfterlifeColors.electricPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AfterlifeColors.electricPurple),
              ),
              child: Column(
                children: [
                  Text(
                    'TURNO DE:',
                    style: TextStyle(
                      color: AfterlifeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCurrentVoter().toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vota en privado, nadie más mira',
                    style: TextStyle(
                      color: AfterlifeColors.textSecondary,
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
                    color: AfterlifeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
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
      resultado = 'PIERDE OPCIÓN A\nBeben los que votaron A';
    } else if (_votesB < _votesA) {
      resultado = 'PIERDE OPCIÓN B\nBeben los que votaron B';
    } else {
      resultado = 'EMPATE\nBEBEN TODOS';
      colorResultado = AfterlifeColors.acidGreen;
    }
    
    return AfterlifeCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorResultado.withOpacity(0.2),
              AfterlifeColors.electricPurple.withOpacity(0.2),
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
                  color: Colors.white24,
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
                color: colorResultado.withOpacity(0.2),
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
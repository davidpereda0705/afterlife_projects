// lib/screens/would_you_rather_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

// no local definition needed; use AvatarStatus from AfterLife_Avatar.dart

class WouldYouRatherGame extends StatefulWidget {
  const WouldYouRatherGame({super.key});

  @override
  State<WouldYouRatherGame> createState() => _WouldYouRatherGameState();
}

class _WouldYouRatherGameState extends State<WouldYouRatherGame> {
  // Categoría seleccionada
  String _selectedCategory = 'normal';
  
  // Dilema actual (dos opciones)
  String _currentOptionA = 'Toca un botón';
  String _currentOptionB = 'para empezar';
  
  // Control para mostrar/esconder elementos
  bool _gameStarted = false;

  // Dilemas por categoría
  final Map<String, List<Map<String, String>>> _dilemmas = {
    'normal': [
      {'a': '¿Prefieres poder volar?', 'b': '¿Prefieres ser invisible?'},
      {'a': '¿Prefieres ser muy rico?', 'b': '¿Prefieres ser muy famoso?'},
      {'a': '¿Prefieres vivir en la playa?', 'b': '¿Prefieres vivir en la montaña?'},
      {'a': '¿Prefieres viajar al pasado?', 'b': '¿Prefieres viajar al futuro?'},
      {'a': '¿Prefieres tener un perro?', 'b': '¿Prefieres tener un gato?'},
      {'a': '¿Prefieres desayunar siempre?', 'b': '¿Prefieres cenar siempre?'},
      {'a': '¿Prefieres perder la vista?', 'b': '¿Prefieres perder el oído?'},
      {'a': '¿Prefieres tener superfuerza?', 'b': '¿Prefieres supervelocidad?'},
    ],
    'picante': [
      {'a': '¿Prefieres una noche de pasión?', 'b': '¿Prefieres una noche de risas?'},
      {'a': '¿Prefieres besar a un desconocido?', 'b': '¿Prefieres besar a tu ex?'},
      {'a': '¿Prefieres ligar en una app?', 'b': '¿Prefieres ligar en persona?'},
      {'a': '¿Prefieres una cita romántica?', 'b': '¿Prefieres una cita salvaje?'},
      {'a': '¿Prefieres contar tu experiencia más vergonzosa?', 'b': '¿Prefieres mostrar una foto vergonzosa?'},
      {'a': '¿Prefieres tener una aventura de una noche?', 'b': '¿Prefieres una relación estable?'},
      {'a': '¿Prefieres besar a alguien del grupo?', 'b': '¿Prefieres besar a un desconocido?'},
      {'a': '¿Prefieres que te ghosteen?', 'b': '¿Prefieres ghostear tú?'},
    ],
    'locas': [
      {'a': '¿Prefieres tener 3 brazos?', 'b': '¿Prefieres tener 3 piernas?'},
      {'a': '¿Prefieres vivir bajo el agua?', 'b': '¿Prefieres vivir en el espacio?'},
      {'a': '¿Prefieres comer lo mismo siempre?', 'b': '¿Prefieres no saber qué comes?'},
      {'a': '¿Prefieres hablar con animales?', 'b': '¿Prefieres entender idiomas?'},
      {'a': '¿Prefieres ser un vampiro?', 'b': '¿Prefieres ser un hombre lobo?'},
      {'a': '¿Prefieres vivir 500 años?', 'b': '¿Prefieres vivir 50 años con salud?'},
      {'a': '¿Prefieres tener memoria infinita?', 'b': '¿Prefieres olvidar lo malo?'},
      {'a': '¿Prefieres teletransportarte?', 'b': '¿Prefieres leer mentes?'},
    ],
  };

  // Colores para cada categoría
  final Map<String, Color> _categoryColors = {
    'normal': AfterlifeColors.cyanBlue,
    'picante': AfterlifeColors.neonPink,
    'locas': AfterlifeColors.acidGreen,
  };

  // Obtener dilema aleatorio de la categoría seleccionada
  void _getRandomDilemma() {
    final categoryDilemmas = _dilemmas[_selectedCategory]!;
    final random = Random();
    final index = random.nextInt(categoryDilemmas.length);
    final dilemma = categoryDilemmas[index];
    setState(() {
      _currentOptionA = dilemma['a']!;
      _currentOptionB = dilemma['b']!;
      _gameStarted = true;
    });
  }

  // Acción para elegir opción A
  void _chooseOptionA() {
    if (!_gameStarted) {
      _getRandomDilemma();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Has elegido la opción A!'),
          backgroundColor: AfterlifeColors.cyanBlue,
          duration: const Duration(milliseconds: 500),
        ),
      );
      _getRandomDilemma();
    }
  }

  // Acción para elegir opción B
  void _chooseOptionB() {
    if (!_gameStarted) {
      _getRandomDilemma();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Has elegido la opción B!'),
          backgroundColor: AfterlifeColors.neonPink,
          duration: const Duration(milliseconds: 500),
        ),
      );
      _getRandomDilemma();
    }
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AfterlifeAvatar(
              initials: 'CR',
              status: AvatarStatus.online,
              size: 40,
              showStatusIndicator: true,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selector de categorías
          _buildCategorySelector(),
          
          const SizedBox(height: 24),
          
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
                      Icons.balance_outlined,
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
                    child: Text(
                      _currentOptionA,
                      style: AfterlifeTextTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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
                    child: Text(
                      _currentOptionB,
                      style: AfterlifeTextTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  if (!_gameStarted) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Selecciona una categoría y empieza',
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
          
          // Botones de acción
          Row(
            children: [
              // Botón OPCIÓN A
              Expanded(
                child: AfterButton(
                  label: 'OPCIÓN A',

                  color: AfterlifeColors.cyanBlue,
                  onPressed: _chooseOptionA,
                ),
              ),
              const SizedBox(width: 12),
              // Botón OPCIÓN B
              Expanded(
                child: AfterButton(
                  label: 'OPCIÓN B',

                  color: AfterlifeColors.neonPink,
                  onPressed: _chooseOptionB,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Texto explicativo
          Center(
            child: Text(
              'Elige una opción y bebe si eres el único que la ha elegido',
              style: TextStyle(
                color: AfterlifeColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Selector de categorías
  Widget _buildCategorySelector() {
    return AfterlifeCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATEGORÍA',
              style: TextStyle(
                color: AfterlifeColors.electricLilac,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCategoryChip('normal', '😊 Normal'),
                const SizedBox(width: 8),
                _buildCategoryChip('picante', '🌶️ Picante'),
                const SizedBox(width: 8),
                _buildCategoryChip('locas', '🤪 Locas'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Chip de categoría
  Widget _buildCategoryChip(String category, String label) {
    final bool isSelected = _selectedCategory == category;
    final Color color = _categoryColors[category]!;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : color.withOpacity(0.7),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
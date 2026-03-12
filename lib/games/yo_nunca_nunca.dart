import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart'; // Tu botón circular

class YoNuncaGame extends StatefulWidget {
  const YoNuncaGame({super.key});

  @override
  State<YoNuncaGame> createState() => _YoNuncaGameState();
}

class _YoNuncaGameState extends State<YoNuncaGame> {
  final List<String> _frases = [
    "Yo nunca nunca he besado a alguien de esta sala.",
    "Yo nunca nunca he enviado un mensaje por error a mi ex.",
    "Yo nunca nunca he fingido estar sobrio delante de mis padres.",
    "Yo nunca nunca me he despertado sin saber dónde estaba.",
    "Yo nunca nunca he mentido en este juego.",
    "Yo nunca nunca he llorado en una discoteca.",
    "Yo nunca nunca he tenido un perfil falso en redes sociales.",
    "Yo nunca nunca me he liado con el/la ex de un amigo.",
    // --- NIVEL PRINCIPIANTE (Calentando) ---
    "Yo nunca nunca he bebido directamente de la botella de otro.",
    "Yo nunca nunca he dicho que no iba a salir y he acabado cerrando la discoteca.",
    "Yo nunca nunca he fingido estar sobrio delante de mis padres.",
    "Yo nunca nunca me he equivocado de baño en un bar.",
    "Yo nunca nunca he robado un vaso de un local.",
    "Yo nunca nunca me he caído en público estando de fiesta.",
    "Yo nunca nunca he perdido el móvil o la cartera de fiesta.",
    
    // --- NIVEL FIESTA (Intermedio) ---
    "Yo nunca nunca he olvidado el nombre de la persona con la que me estaba besando.",
    "Yo nunca nunca he subido una storie borracho y me he arrepentido al despertar.",
    "Yo nunca nunca he bailado encima de una mesa o de la barra.",
    "Yo nunca nunca he mentido para que me dejaran entrar en un reservado.",
    "Yo nunca nunca he usado una app de citas estando dentro de una discoteca.",
    "Yo nunca nunca he hecho un 'simpa' (irse sin pagar).",
    "Yo nunca nunca me he colado en una fiesta privada.",
    "Yo nunca nunca he besado a más de dos personas en la misma noche.",
    "Yo nunca nunca he intentado entrar a un club con el DNI de otra persona.",

    // --- NIVEL AFTERLIFE (Atrevidas/Comprometidas) ---
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

  void _nextFrase() {
    setState(() {
      if (_currentIndex < _frases.length - 1) {
        _currentIndex++;
      } else {
        _frases.shuffle(); // Mezclar al terminar
        _currentIndex = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _frases.shuffle(); // Empezar con orden aleatorio
  }

  @override
  Widget build(BuildContext context) {
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
          gradient: AfterlifeColors.electricLilacGradient, // Tu gradiente
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Barra de progreso sutil
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _frases.length,
                backgroundColor: Colors.white10,
                color: const Color(0xFFEC4899), // Tu neonPink
              ),
              const SizedBox(height: 40),

              // Tarjeta principal del juego
              Expanded(
                child: AfterlifeCard(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: const Color(0xFFEC4899),
                          size: 50,
                        ),
                        const SizedBox(height: 30),
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
                            fontSize: 26,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Botón para pasar (usando tu AfterButton circular)
              AfterButton(
                label: 'SIGUIENTE',
                color: const Color(0xFFEC4899),
                onPressed: _nextFrase,
              ),
              
              const SizedBox(height: 20),
              Text(
                "Si lo has hecho, ¡BEBE!",
                style: AfterlifeTextTheme.bodySmall.copyWith(
                  color: AfterlifeColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/reto_rapido.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:afterlife_projects/components/AfterButton.dart';

class RetoRapidoGame extends StatefulWidget {
  const RetoRapidoGame({super.key});

  @override
  State<RetoRapidoGame> createState() => _RetoRapidoGameState();
}

class _RetoRapidoGameState extends State<RetoRapidoGame> {
  // --- LISTA DE 30 RETOS ---
  final List<String> _retos = [
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

  int _currentIndex = 0;
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _retos.shuffle(); // Mezclamos al iniciar
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 30;
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        setState(() => _isTimerRunning = false);
        _showTimeOutDialog();
      }
    });
  }

  void _nextReto() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _secondsLeft = 30;
      if (_currentIndex < _retos.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
        _retos.shuffle();
      }
    });
  }

  void _showTimeOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AfterlifeColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF06B6D4))),
        title: Text("¡TIEMPO AGOTADO!", style: AfterlifeTextTheme.titleMedium.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("No lo has conseguido a tiempo... ¡TE TOCA BEBER!", style: AfterlifeTextTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("VALE, ACEPTO", style: TextStyle(color: AfterlifeColors.electricPurple)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // --- INDICADOR CIRCULAR ---
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
              const SizedBox(height: 40),

              // --- TARJETA DEL RETO ---
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
                          _retos[_currentIndex],
                          textAlign: TextAlign.center,
                          style: AfterlifeTextTheme.titleLarge.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTONES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isTimerRunning)
                    AfterButton(
                      label: '¡DALE!',
                      color: const Color(0xFF06B6D4),
                      onPressed: _startTimer,
                    ),
                  if (_isTimerRunning || _secondsLeft == 0)
                    AfterButton(
                      label: 'SIGUIENTE',
                      color: AfterlifeColors.electricPurple,
                      onPressed: _nextReto,
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
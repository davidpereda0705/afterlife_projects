// lib/screens/night_summary_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:afterlife_projects/Home.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_theme.dart';
import '../components/AfterLife_Avatar.dart';
import '../components/AfterButton.dart';

class NightSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> nightData;

  const NightSummaryScreen({super.key, required this.nightData});

  @override
  State<NightSummaryScreen> createState() => _NightSummaryScreenState();
}

class _NightSummaryScreenState extends State<NightSummaryScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Datos del podio (3º, 2º, 1º)
  List<Map<String, dynamic>> _podiumPlayers = [];
  int _podiumIndex = 0;

  // Para el carrusel de imágenes
  PageController _pageController = PageController();
  Timer? _carouselTimer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Preparar podio (tercero, segundo, primero)
    final players = _getSortedPlayers();
    if (players.length >= 3) {
      _podiumPlayers = [players[2], players[1], players[0]];
    } else {
      _podiumPlayers = players.reversed.toList();
    }

    _startStep();
  }

  List<Map<String, dynamic>> _getSortedPlayers() {
    final players = List<Map<String, dynamic>>.from(
      widget.nightData['players'] ?? [],
    );
    players.sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));
    return players;
  }

  void _startStep() {
    _controller.forward(from: 0.0);
    if (_currentStep == 1) {
      // Paso del podio: comenzar animación secuencial
      _startPodiumSequence();
    } else if (_currentStep == 3) {
      _startCarousel('challenge');
    } else if (_currentStep == 4) {
      _startCarousel('night');
    }
  }

  void _startPodiumSequence() {
    _podiumIndex = 0;
    _showNextPodium();
  }

  void _showNextPodium() {
    if (_podiumIndex < _podiumPlayers.length) {
      // Mostrar el jugador actual
      setState(() {});
      // Tiempo más largo para que se vea bien
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _podiumIndex++;
          _showNextPodium();
        }
      });
    } else {
      // Terminado el podio, pasar al siguiente paso automáticamente
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _nextStep();
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      _controller.reset();
      _controller.forward();
      _stopCarousel();
      if (_currentStep == 1) {
        _startPodiumSequence();
      } else if (_currentStep == 3) {
        _startCarousel('challenge');
      } else if (_currentStep == 4) {
        _startCarousel('night');
      }
    }
  }

  void _startCarousel(String type) {
    final photos = (type == 'challenge')
        ? _getChallengePhotos()
        : _getNightPhotos();
    if (photos.isEmpty) {
      // Si no hay fotos, saltamos al siguiente paso después de un breve tiempo
      Future.delayed(const Duration(seconds: 1), _nextStep);
      return;
    }
    _pageController = PageController(initialPage: 0);
    _currentImageIndex = 0;
    _carouselTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentImageIndex < photos.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      _pageController.animateToPage(
        _currentImageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = null;
  }

  @override
  void dispose() {
    _stopCarousel();
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ---- Datos para las fotos ----
  List<Map<String, dynamic>> _getChallengePhotos() {
    final challenges = widget.nightData['challenges'] ?? [];
    List<Map<String, dynamic>> photos = [];
    for (var challenge in challenges) {
      if (challenge['proofBytes'] != null) {
        photos.add({
          'bytes': challenge['proofBytes'],
          'title': challenge['name'],
          'completedBy': challenge['completedBy'] ?? 'Alguien',
        });
      }
    }
    return photos;
  }

  List<Map<String, dynamic>> _getNightPhotos() {
    final nightPhotos = widget.nightData['nightPhotos'] ?? [];
    List<Map<String, dynamic>> photos = [];
    for (var item in nightPhotos) {
      // La estructura puede ser bytes directo o mapa {bytes}
      if (item is Uint8List) {
        photos.add({'bytes': item});
      } else if (item is Map && item.containsKey('bytes')) {
        photos.add({'bytes': item['bytes']});
      }
    }
    return photos;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
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
          'Resumen de la noche',
          style: AfterlifeTextTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _nextStep,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Fondo con gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AfterlifeColors.electricLilac.withOpacity(0.3),
                      AfterlifeColors.background,
                    ],
                  ),
                ),
              ),
              // Contenido animado según el paso
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildStepContent(_currentStep),
              ),
              // Indicador de paso (excepto en resumen final)
              if (_currentStep != 5)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentStep
                              ? AfterlifeColors.electricLilac
                              : Colors.white.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildIntro();
      case 1:
        return _buildPodium();
      case 2:
        return _buildRanking();
      case 3:
        return _buildChallengePhotos();
      case 4:
        return _buildNightPhotos();
      case 5:
        return _buildFinalSummary();
      default:
        return _buildIntro();
    }
  }

  // ---- PASO 0: INTRO ----
  Widget _buildIntro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                widget.nightData['name'] ?? 'Noche sin nombre',
                style: AfterlifeTextTheme.headlineLarge.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AfterlifeColors.electricLilac,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              '¡Qué noche!',
              style: AfterlifeTextTheme.bodyLarge.copyWith(
                color: AfterlifeColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- PASO 1: PODIO (3º, 2º, 1º secuencial) MEJORADO ----
  Widget _buildPodium() {
    if (_podiumPlayers.isEmpty) {
      return Center(
        child: Text(
          'No hay participantes',
          style: TextStyle(color: AfterlifeColors.textSecondary),
        ),
      );
    }

    // Mostrar el jugador actual del podio
    final player = _podiumPlayers[_podiumIndex];
    final int position = _podiumPlayers.length - _podiumIndex; // 3,2,1
    final String positionText = position == 1 ? '🏆 GANADOR 🏆' : '$positionº LUGAR';
    final Color color = position == 1
        ? const Color(0xFFF59E0B)
        : position == 2
            ? Colors.grey[400]!
            : Colors.brown[300]!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.5), Colors.transparent],
                  ),
                ),
                child: AfterlifeAvatar(
                  initials: _getInitials(player['name'] ?? '?'),
                  status: AvatarStatus.online,
                  size: 120,
                  showStatusIndicator: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              positionText,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              player['name'] ?? 'Jugador',
              style: AfterlifeTextTheme.headlineMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${player['points'] ?? 0} pts',
                style: TextStyle(color: color, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- PASO 2: TABLA DE CLASIFICACIÓN (sin botón) ----
  Widget _buildRanking() {
    final players = _getSortedPlayers();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CLASIFICACIÓN FINAL',
              style: TextStyle(
                color: Color(0xFFEC4899),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(players.length, (index) {
              final player = players[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? const Color(0xFFF59E0B).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == 0
                                ? const Color(0xFFF59E0B)
                                : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        player['name'] ?? 'Jugador',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${player['points'] ?? 0} pts',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---- PASO 3: FOTOS DE LOS RETOS (carrusel con información) ----
  Widget _buildChallengePhotos() {
    final photos = _getChallengePhotos();
    if (photos.isEmpty) {
      return Center(
        child: Text(
          'No hay fotos de retos',
          style: TextStyle(color: AfterlifeColors.textSecondary),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '📸 RETOS COMPLETADOS',
          style: TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final item = photos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          item['bytes'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title'],
                      style: AfterlifeTextTheme.titleMedium.copyWith(
                        color: AfterlifeColors.cyanBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completado por: ${item['completedBy']}',
                      style: TextStyle(color: AfterlifeColors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- PASO 4: FOTOS DE LA NOCHE (sin texto de subida) ----
  Widget _buildNightPhotos() {
    final photos = _getNightPhotos();
    if (photos.isEmpty) {
      return Center(
        child: Text(
          'No hay fotos de la noche',
          style: TextStyle(color: AfterlifeColors.textSecondary),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '📸 MOMENTOS DE LA NOCHE',
          style: TextStyle(
            color: Color(0xFFEC4899),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final item = photos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          item['bytes'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- PASO 5: RESUMEN FINAL (con zoom y cierre tocando fuera) ----
  Widget _buildFinalSummary() {
    final players = _getSortedPlayers();
    final challengePhotos = _getChallengePhotos();
    final nightPhotos = _getNightPhotos();
    final allPhotos = [...challengePhotos, ...nightPhotos];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre de la noche
          Center(
            child: Text(
              widget.nightData['name'] ?? 'Noche sin nombre',
              style: AfterlifeTextTheme.headlineLarge.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AfterlifeColors.electricLilac,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Clasificación compacta
          const Text(
            'CLASIFICACIÓN',
            style: TextStyle(
              color: Color(0xFFEC4899),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(players.length, (index) {
            final player = players[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? const Color(0xFFF59E0B).withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index == 0
                              ? const Color(0xFFF59E0B)
                              : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      player['name'] ?? 'Jugador',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    '${player['points'] ?? 0} pts',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Fotos (grid de 2 columnas) con zoom y cierre tocando fuera
          if (allPhotos.isNotEmpty) ...[
            const Text(
              '📸 FOTOS',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: allPhotos.length,
              itemBuilder: (context, index) {
                final item = allPhotos[index];
                return GestureDetector(
                  onTap: () => _showFullscreenImage(context, item['bytes']),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      item['bytes'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 30),

          // Botón para volver al inicio
          AfterButton(
            label: 'VOLVER AL INICIO',
            color: AfterlifeColors.electricLilac,
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) =>  HomeScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Fondo semitransparente que cierra al tocarlo
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black.withOpacity(0.9),
            ),
          ),
          // Imagen centrada y que no cierra al tocarla
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Botón de cierre opcional (también cierra)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
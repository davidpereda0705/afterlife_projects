// lib/screens/night_summary_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:afterlife_projects/main_screen.dart';
import 'package:confetti/confetti.dart';
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

  List<Map<String, dynamic>> _podiumPlayers = [];
  int _podiumIndex = 0;

  PageController _pageController = PageController();
  Timer? _carouselTimer;
  int _currentImageIndex = 0;

  late ConfettiController _confettiController;

  // Convierte cualquier tipo de lista a Uint8List para evitar errores
  Uint8List _toUint8List(dynamic data) {
    if (data == null) return Uint8List(0);
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    if (data is List<dynamic>) {
      try {
        return Uint8List.fromList(data.cast<int>().toList());
      } catch (e) {
        return Uint8List(0);
      }
    }
    return Uint8List(0);
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    final players = _getSortedPlayers();
    if (players.length >= 3) {
      _podiumPlayers = [players[2], players[1], players[0]];
    } else {
      _podiumPlayers = players.reversed.toList();
    }

    _startStep();
  }

  List<Map<String, dynamic>> _getSortedPlayers() {
    final players = List<Map<String, dynamic>>.from(widget.nightData['players'] ?? []);
    players.sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));
    return players;
  }

  void _startStep() {
    _controller.forward(from: 0.0);
    if (_currentStep == 1) {
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
      setState(() {});
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _podiumIndex++;
          _showNextPodium();
        }
      });
    } else {
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
      } else if (_currentStep == 5) {
        _confettiController.play();
      }
    }
  }

  void _startCarousel(String type) {
    final photos = (type == 'challenge') ? _getChallengePhotos() : _getNightPhotos();
    if (photos.isEmpty) {
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
    _confettiController.dispose();
    super.dispose();
  }

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

  void _goToMainScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToMainScreen();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _goToMainScreen,
          ),
          title: Text(
            'Resumen de la noche',
            style: AfterlifeTextTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
          onTap: _nextStep,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AfterlifeColors.electricLilac.withValues(alpha: 0.3),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildStepContent(_currentStep),
                ),
                if (_currentStep == 5)
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: [
                        AfterlifeColors.electricLilac,
                        AfterlifeColors.neonPink,
                        AfterlifeColors.acidGreen,
                        AfterlifeColors.cyanBlue,
                      ],
                    ),
                  ),
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
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- PASO 1: PODIO ----
  Widget _buildPodium() {
    if (_podiumPlayers.isEmpty) {
      return Center(
        child: Text(
          'No hay participantes',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }

    final player = _podiumPlayers[_podiumIndex];
    final int position = _podiumPlayers.length - _podiumIndex;
    final String positionText = position == 1 ? '🏆 GANADOR 🏆' : '$positionº LUGAR';
    final Color color = position == 1
        ? AfterlifeColors.neonOrange
        : position == 2
            ? Theme.of(context).disabledColor
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

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
                    colors: [color.withValues(alpha: 0.5), Colors.transparent],
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
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
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

  // ---- PASO 2: TABLA DE CLASIFICACIÓN ----
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
                color: AfterlifeColors.neonPink,
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
                            ? AfterlifeColors.neonOrange.withValues(alpha: 0.2)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == 0
                                ? AfterlifeColors.neonOrange
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        player['name'] ?? 'Jugador',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AfterlifeColors.neonOrange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${player['points'] ?? 0} pts',
                        style: const TextStyle(
                          color: AfterlifeColors.neonOrange,
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

  // ---- PASO 3: FOTOS DE LOS RETOS (CORREGIDO) ----
  Widget _buildChallengePhotos() {
    final photos = _getChallengePhotos();
    if (photos.isEmpty) {
      return Center(
        child: Text(
          'No hay fotos de retos',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '📸 RETOS COMPLETADOS',
          style: TextStyle(
            color: AfterlifeColors.cyanBlue,
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
              final bytes = _toUint8List(item['bytes']);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: bytes.isEmpty
                            ? Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
                                ),
                              )
                            : Image.memory(bytes, fit: BoxFit.cover),
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
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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

  // ---- PASO 4: FOTOS DE LA NOCHE (CORREGIDO) ----
  Widget _buildNightPhotos() {
    final photos = _getNightPhotos();
    if (photos.isEmpty) {
      return Center(
        child: Text(
          'No hay fotos de la noche',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '📸 MOMENTOS DE LA NOCHE',
          style: TextStyle(
            color: AfterlifeColors.neonPink,
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
              final bytes = _toUint8List(item['bytes']);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: bytes.isEmpty
                            ? Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
                                ),
                              )
                            : Image.memory(bytes, fit: BoxFit.cover),
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

  // ---- PASO 5: RESUMEN FINAL ----
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

          const Text(
            'CLASIFICACIÓN',
            style: TextStyle(
              color: AfterlifeColors.neonPink,
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
                          ? AfterlifeColors.neonOrange.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index == 0
                              ? AfterlifeColors.neonOrange
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
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
           style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    ),
                  ),
                  Text(
                    '${player['points'] ?? 0} pts',
                    style: const TextStyle(
                      color: AfterlifeColors.neonOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          if (allPhotos.isNotEmpty) ...[
            const Text(
              '📸 FOTOS',
              style: TextStyle(
                color: AfterlifeColors.cyanBlue,
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
                final bytes = _toUint8List(item['bytes']);
                return GestureDetector(
                  onTap: () => _showFullscreenImage(context, bytes),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: bytes.isEmpty
                        ? Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white54),
                            ),
                          )
                        : Image.memory(bytes, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 30),

          AfterButton(
            label: 'VOLVER AL INICIO',
            color: AfterlifeColors.electricLilac,
            onPressed: _goToMainScreen,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, Uint8List imageBytes) {
    if (imageBytes.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
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
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
       icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
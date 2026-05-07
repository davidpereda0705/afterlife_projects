import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AfterlifeColors.textPrimaryAdaptive(context);
    final subtitleColor = AfterlifeColors.textSecondaryAdaptive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Cómo funciona?'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _HeroBanner(isDark: isDark),
          const SizedBox(height: 28),
          _SectionLabel('LOS BÁSICOS', AfterlifeColors.electricPurple),
          const SizedBox(height: 12),
          _StepCard(
            step: 1,
            icon: Icons.add_circle_outline,
            iconColor: AfterlifeColors.electricPurple,
            title: 'Crea una Noche',
            body:
                'El anfitrión pulsa "Crear Noche", le pone nombre y elige el tipo. Se genera un código único que comparte con sus amigos.',
            example: '💡 Ejemplo: "Fiesta de fin de curso" con código AB34X',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _StepCard(
            step: 2,
            icon: Icons.group_add,
            iconColor: AfterlifeColors.neonPink,
            title: 'Únete con el código',
            body:
                'Tus amigos pulsan "Unirse" e introducen el código. Todos aparecéis en la misma sala y podéis ver quién ha entrado.',
            example: '💡 Hasta 10 personas pueden unirse a la misma noche.',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _StepCard(
            step: 3,
            icon: Icons.task_alt,
            iconColor: AfterlifeColors.cyanBlue,
            title: 'Completa Retos',
            body:
                'Durante la noche se os asignan retos en tiempo real. Complétalo, haz que otro lo verifique y gana XP. Los retos van de fácil a épico.',
            example:
                '💡 Ejemplo de reto: "Haz una foto con alguien que no conozcas" → 150 XP',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          const SizedBox(height: 24),
          _SectionLabel('MÁS FUNCIONES', AfterlifeColors.neonPink),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.sports_esports,
            iconColor: AfterlifeColors.acidGreen,
            title: 'Minijuegos para la previa',
            body:
                'Antes de salir podéis jugar juntos. Hay cuatro modos: Yo Nunca Nunca, Verdad o Beto, ¿Qué preferirías? y Reto Rápido. Son perfectos para romper el hielo.',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _FeatureCard(
            icon: Icons.emoji_events,
            iconColor: AfterlifeColors.neonOrange,
            title: 'Logros',
            body:
                'Se desbloquean automáticamente cuando cumples condiciones: primera noche, 5 retos seguidos, 10 noches completadas... Algunos son secretos.',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _FeatureCard(
            icon: Icons.menu_book_outlined,
            iconColor: AfterlifeColors.cyanBlue,
            title: 'Diario de noches',
            body:
                'Cada noche queda guardada con los retos completados, los puntos ganados y un resumen. Puedes revisarlas cuando quieras.',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _FeatureCard(
            icon: Icons.leaderboard,
            iconColor: AfterlifeColors.electricPurple,
            title: 'Ranking',
            body:
                'Compite con tus amigos por el top. El XP se acumula con cada noche y reto completado. Sube de nivel para desbloquear nuevas recompensas.',
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          const SizedBox(height: 24),
          _SectionLabel('CONSEJOS PRO', AfterlifeColors.acidGreen),
          const SizedBox(height: 12),
          _TipsCard(
            isDark: isDark,
            tips: [
              '⚡  Completa los retos cuanto antes: dan más XP si los haces pronto.',
              '🔥  Juega en la previa: los minijuegos calientan el ambiente.',
              '🏆  Busca los logros secretos: hay sorpresas para los más valientes.',
              '📸  El Diario guarda todo: no borres las noches, son tus recuerdos.',
              '👥  Cuantos más amigos se unan, más épica es la noche.',
            ],
            textColor: textColor,
          ),
          const SizedBox(height: 32),
          if (Navigator.canPop(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AfterButton(
                label: '¡LISTO, A JUGAR!',
                color: AfterlifeColors.electricPurple,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final bool isDark;
  const _HeroBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A0533), const Color(0xFF0D1A33)]
              : [const Color(0xFFF3E8FF), const Color(0xFFE0F7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AfterlifeColors.electricPurple.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AfterlifeColors.heroGradient.createShader(bounds),
            child: const Text(
              'AFTERLIFE',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Convierte cada salida con amigos en una aventura. Retos, minijuegos, logros y recuerdos — todo en la misma app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 14,
              height: 1.5,
              color: AfterlifeColors.textSecondaryAdaptive(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String example;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.example,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 13,
              height: 1.5,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Text(
              example,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 12,
                height: 1.4,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AfterlifeColors.electricPurple.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 12,
                    height: 1.5,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final bool isDark;
  final List<String> tips;
  final Color textColor;

  const _TipsCard({
    required this.isDark,
    required this.tips,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1A0D) : const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AfterlifeColors.acidGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              tip,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AfterlifeColors.acidGreen.withValues(alpha: 0.9)
                    : const Color(0xFF1B5E20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

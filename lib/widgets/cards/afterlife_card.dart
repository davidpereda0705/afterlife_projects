// Tarjeta base de la app con fondo semi-transparente, bordes redondeados y soporte de tema claro/oscuro.
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class AfterlifeCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;

  const AfterlifeCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = backgroundColor ??
        (isDark ? const Color(0xFF0D0D1A) : Theme.of(context).cardColor);
    final radius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: radius,
        // Gradient glow shadow
        boxShadow: [
          BoxShadow(
            color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AfterlifeColors.neonPink.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Gradient border via nested containers
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            colors: [
              AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.6 : 0.4),
              AfterlifeColors.neonPink.withValues(alpha: isDark ? 0.4 : 0.3),
              AfterlifeColors.cyanBlue.withValues(alpha: isDark ? 0.3 : 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(1.5), // border width
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius as BorderRadius,
            splashColor: AfterlifeColors.electricPurple.withValues(alpha: 0.15),
            highlightColor: AfterlifeColors.neonPink.withValues(alpha: 0.08),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: radius,
              ),
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

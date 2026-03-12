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
    final cardColor =
        backgroundColor ?? AfterlifeColors.electricLilac.withOpacity(0.15);

    final radius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius as BorderRadius,
          splashColor: AfterlifeColors.electricLilac,
          highlightColor: AfterlifeColors.neonPink,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: radius,
              border: Border.all(
                color: AfterlifeColors.electricLilac,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
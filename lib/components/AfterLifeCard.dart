// lib/core/widgets/afterlife_card.dart
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
    final cardColor = backgroundColor ?? AfterlifeColors.electricLilac.withOpacity(0.15);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: (borderRadius ?? BorderRadius.circular(16)) as BorderRadius,
        child: InkWell(
          onTap: onTap, 
          borderRadius: (borderRadius ?? BorderRadius.circular(16)) as BorderRadius,
          splashColor: AfterlifeColors.electricLilac,
          highlightColor: AfterlifeColors.neonPink,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: AfterlifeColors.electricLilac,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
// lib/core/widgets/afterlife_bottom_nav.dart
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';

class AfterlifeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const AfterlifeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        gradient: AfterlifeColors.bottomNavGradient(context),
        border: Border(
          top: BorderSide(
            color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.35 : 0.2),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 75,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = currentIndex == index;

                return _buildNavItem(
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  unselectedColor: unselectedColor,
                  isDark: isDark,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color unselectedColor,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFA855F7),
                          Color(0xFFEC4899),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AfterlifeColors.electricPurple.withValues(alpha: isDark ? 0.4 : 0.25),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? Colors.white : unselectedColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? AfterlifeColors.electricPurple : unselectedColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                letterSpacing: isSelected ? 0.5 : 0,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AfterlifeColors.neonPink,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AfterlifeColors.neonPink.withValues(alpha: isDark ? 0.7 : 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

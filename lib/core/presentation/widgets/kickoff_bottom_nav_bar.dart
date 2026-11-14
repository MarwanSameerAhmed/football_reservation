import 'package:flutter/material.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({required this.icon, required this.label});
}

/// Executive Floating Dock Bottom Navigation Bar matching the Formtor theme.
class KickoffBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const KickoffBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final activeColor = cs.primary;
    final inactiveColor = cs.onSurfaceVariant;
    final activePillBg = activeColor.withValues(alpha: isDark ? 0.18 : 0.10);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive(standard: 16.0, compact: 12.0),
          vertical: 8.0,
        ),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.outlineVariant,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final isSelected = index == currentIndex;
              final item = items[index];

              return Expanded(
                child: Semantics(
                  selected: isSelected,
                  button: true,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(13),
                    child: Center(
                      child: AnimatedContainer(
                        duration: KickoffMotion.accessible(
                          context,
                          KickoffMotion.stateChange,
                        ),
                        curve: KickoffMotion.enter,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 14 : 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? activePillBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected ? activeColor : inactiveColor,
                                size: 22,
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 7),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: activeColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

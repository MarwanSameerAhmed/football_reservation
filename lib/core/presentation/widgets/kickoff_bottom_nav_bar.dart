import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({required this.icon, required this.label});
}

/// Floating Capsule Bottom Navigation Bar strictly matching the reference design.
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
    final navBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final activeCapsuleBg = isDark
        ? AppColors.turfGreenNeon
        : AppColors.darkSlate;
    final activeTextColor = isDark ? AppColors.darkSlate : Colors.white;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive(standard: 16.0, compact: 10.0),
          vertical: 8.0,
        ),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
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
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    child: Center(
                      child: isSelected
                          ? AnimatedContainer(
                              duration: AppConstants.quickAnimation,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: activeCapsuleBg,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusCircular,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.icon,
                                      color: activeTextColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.label,
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                            color: activeTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.icon,
                                      color: inactiveColor,
                                      size: 20,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.label,
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: inactiveColor,
                                            fontSize: 10,
                                          ),
                                      maxLines: 1,
                                    ),
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

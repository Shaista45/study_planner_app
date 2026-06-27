import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class SoftBottomNavBar extends StatelessWidget {
  const SoftBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isAddEnabled,
    required this.onTap,
  });

  final int currentIndex;
  final bool isAddEnabled;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = const <_NavItem>[
      _NavItem(Icons.home_rounded, 'Home'),
      _NavItem(Icons.note_add_rounded, 'Add'),
      _NavItem(Icons.insights_rounded, 'Progress'),
      _NavItem(Icons.settings_rounded, 'Settings'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.softSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.deepBrown.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(items.length, (int index) {
            final bool selected = currentIndex == index;
            final bool disabled = index == 1 && !isAddEnabled;
            final Color activeColor = disabled
                ? Colors.grey.shade400
                : AppColors.deepBrown;
            final Color inactiveColor = disabled
                ? Colors.grey.shade400
                : AppColors.deepBrown.withValues(alpha: 0.55);
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? (disabled
                            ? Colors.grey.shade300
                            : AppColors.secondaryYellow.withValues(alpha: 0.35))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      items[index].icon,
                      color: selected ? activeColor : inactiveColor,
                    ),
                    if (selected) ...<Widget>[
                      const SizedBox(width: 6),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: activeColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

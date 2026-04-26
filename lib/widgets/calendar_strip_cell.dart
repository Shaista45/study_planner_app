import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class CalendarStripCell extends StatelessWidget {
  const CalendarStripCell({
    super.key,
    required this.dayLabel,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
  });

  final String dayLabel;
  final int dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryOlive : AppColors.softSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.deepBrown.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? AppColors.deepBrown
                          : AppColors.deepBrown.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.deepBrown
                          : AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

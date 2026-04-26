import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class CalendarGridCell extends StatelessWidget {
  const CalendarGridCell({
    super.key,
    required this.value,
    this.highlight = false,
  });

  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.secondaryYellow
            : AppColors.softSurface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: highlight
              ? AppColors.deepBrown
              : AppColors.deepBrown.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

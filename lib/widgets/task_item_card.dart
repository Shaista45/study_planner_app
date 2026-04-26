import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class TaskItemCard extends StatelessWidget {
  const TaskItemCard({
    super.key,
    required this.title,
    required this.status,
    required this.dotColor,
    required this.onTap,
    this.heroTag,
  });

  final String title;
  final String status;
  final Color dotColor;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final bool done = status.toLowerCase() == 'done';

    final Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.deepBrown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: done ? AppColors.primaryOlive : AppColors.accentOrange,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: AppColors.deepBrown,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    if (heroTag == null) {
      return card;
    }

    return Hero(
      tag: heroTag!,
      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection direction,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            return Material(
              color: Colors.transparent,
              child: toHeroContext.widget,
            );
          },
      child: card,
    );
  }
}

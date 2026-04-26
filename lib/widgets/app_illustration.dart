import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class AppIllustration extends StatelessWidget {
  const AppIllustration({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.small = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final double size = small ? 84 : 120;

    return Column(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryOlive.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Icon(icon, size: small ? 44 : 56, color: AppColors.deepBrown),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

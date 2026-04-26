import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';

enum CustomButtonVariant { filled, outlined }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.variant = CustomButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final CustomButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool isFilled = variant == CustomButtonVariant.filled;

    final Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isFilled ? AppColors.secondaryYellow : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFilled ? AppColors.secondaryYellow : AppColors.primaryOlive,
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: AppColors.deepBrown, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.deepBrown,
            ),
          ),
        ],
      ),
    );

    return AnimatedScaleButton(
      onTap: onPressed,
      child: expand ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}

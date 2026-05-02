import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool showArrow;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primaryGreen,
    this.showArrow = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryGradient;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: AppRadius.mdBr,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
              if (showArrow) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

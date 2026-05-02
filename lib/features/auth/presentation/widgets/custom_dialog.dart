import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlBr),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 48,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(duration: 300.ms),
            const SizedBox(height: AppSpacing.xl),
            Text(
              "Account Created!",
              style: AppTypography.headlineMedium.copyWith(
                color: context.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Your RD Fresh account is ready. You can now track your shipments.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.go('/');
                },
                child: const Text("Go to Dashboard"),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 400.ms,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}

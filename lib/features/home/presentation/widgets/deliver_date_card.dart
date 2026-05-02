import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DeliveryDateCard extends StatelessWidget {
  const DeliveryDateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.lgBr,
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Expected Delivery Date",
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Jan 28, 2026",
            style: AppTypography.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.pillBr,
            ),
            child: Text(
              "2 days remaining",
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

class ActiveOrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final double progress;
  final bool needsSignature;
  final VoidCallback onPress;

  const ActiveOrderCard({
    super.key,
    required this.onPress,
    required this.orderId,
    required this.date,
    this.progress = 0.6,
    this.needsSignature = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order $orderId",
                style: AppTypography.headlineSmall.copyWith(
                  color: context.textPrimary,
                ),
              ),
              if (needsSignature) AppBadge.error("Signature Required"),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Fresh Produce Box",
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Horizontal Stepper
          const OrderHorizontalStepper(step: 2),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar
          ClipRRect(
            borderRadius: AppRadius.pillBr,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.inputFillColor,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Delivery in progress",
            style: AppTypography.caption.copyWith(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Expected Delivery",
                    style: AppTypography.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: onPress,
                icon: const Text("Sign Now"),
                label: const Icon(Icons.chevron_right_rounded, size: 18),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBr,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderHorizontalStepper extends StatelessWidget {
  final int step;
  const OrderHorizontalStepper({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context, Icons.inventory_2_outlined, step >= 1),
        _buildLine(context, step >= 2),
        _buildIcon(context, Icons.local_shipping_outlined, step >= 2),
        _buildLine(context, step >= 3),
        _buildIcon(context, Icons.check_circle_outline, step >= 3),
      ],
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : context.inputFillColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primaryGreen : context.borderColor,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isActive ? AppColors.primaryGreen : context.textTertiary,
      ),
    );
  }

  Widget _buildLine(BuildContext context, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : context.borderColor,
          borderRadius: AppRadius.pillBr,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Status",
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildStatusItem(
            context,
            title: "Order Placed",
            subtitle: "Your order has been confirmed",
            date: "Jan 24, 2026",
            icon: Icons.inventory_2_outlined,
            isCompleted: true,
            isLast: false,
          ),
          _buildStatusItem(
            context,
            title: "In Transit",
            subtitle: "Your shipment is on the way",
            status: "In Progress",
            icon: Icons.local_shipping_outlined,
            isCompleted: true,
            isCurrent: true,
            isLast: false,
          ),
          _buildStatusItem(
            context,
            title: "Delivered",
            subtitle: "Your order will be delivered soon",
            icon: Icons.history_outlined,
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? date,
    String? status,
    required IconData icon,
    required bool isCompleted,
    required bool isLast,
    bool isCurrent = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : context.inputFillColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isCompleted ? Colors.white : context.textTertiary,
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(
                    color: isCompleted
                        ? AppColors.primaryGreen
                        : context.borderColor,
                    thickness: 2,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        date,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  if (status != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        status,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (isCurrent) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadius.pillBr,
                      child: LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: context.inputFillColor,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primaryGreen,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

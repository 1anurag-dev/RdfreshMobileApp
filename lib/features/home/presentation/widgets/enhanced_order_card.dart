import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../delivery/domain/entities/order_entity.dart';

class EnhancedOrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onPress;

  const EnhancedOrderCard({
    super.key,
    required this.order,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool showSignNowButton =
        order.status.toLowerCase() == 'delivered' &&
            order.signatureStatus?.toLowerCase() != 'signed';

    final bool showSignatureWarning =
        order.status.toLowerCase() == 'delivered' &&
            order.signatureStatus?.toLowerCase() != 'signed';

    int getProgressStep() {
      switch (order.status.toLowerCase()) {
        case 'ordered':
        case 'pending':
          return 1;
        case 'processing':
        case 'shipped':
          return 2;
        case 'delivered':
          return 3;
        default:
          return 1;
      }
    }

    final step = getProgressStep();

    return GestureDetector(
      onTap: onPress,
      child: AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ${order.orderId}",
                style: AppTypography.headlineSmall.copyWith(
                  color: context.textPrimary,
                ),
              ),
              if (showSignatureWarning) AppBadge.error("Signature Required"),
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
          OrderHorizontalStepper(step: step),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar
          ClipRRect(
            borderRadius: AppRadius.pillBr,
            child: LinearProgressIndicator(
              value: step / 3.0,
              backgroundColor: context.inputFillColor,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Status
          AppStatusChip(
            label: _formatStatus(order.status),
            color: _getStatusColor(context, order.status),
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
                    "Order Date",
                    style: AppTypography.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(order.orderDate),
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              if (showSignNowButton)
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
    ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return 'Ordered';
      case 'pending':
        return 'Order Placed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      default:
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
      case 'pending':
        return AppColors.statusPending;
      case 'processing':
        return AppColors.statusProcessing;
      case 'shipped':
        return AppColors.statusShipped;
      case 'delivered':
        return AppColors.statusDelivered;
      default:
        return context.textTertiary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class OrderHorizontalStepper extends StatelessWidget {
  final int step;
  const OrderHorizontalStepper({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context, Icons.inventory_2_outlined, step >= 1, "Ordered"),
        _buildLine(context, step >= 2),
        _buildIcon(
            context, Icons.local_shipping_outlined, step >= 2, "Shipped"),
        _buildLine(context, step >= 3),
        _buildIcon(
            context, Icons.check_circle_outline, step >= 3, "Delivered"),
      ],
    );
  }

  Widget _buildIcon(
      BuildContext context, IconData icon, bool isActive, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
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

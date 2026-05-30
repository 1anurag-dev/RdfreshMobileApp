import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/routes/app_routes.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Orders',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.base),
                child: ShimmerList(itemCount: 3, itemHeight: 120),
              );
            }

            if (state is OrderError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: context.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Text(
                        'Unable to load orders',
                        style: AppTypography.titleLarge.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ActiveOrdersLoaded) {
              if (state.orders.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async {
                  context.read<OrderBloc>().add(LoadActiveOrders());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.base,
                    100,
                  ),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return _OrderCard(order: order);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.primaryGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No orders yet',
              style: AppTypography.headlineSmall.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your orders will appear here once you place them.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.products),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pillBr,
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Browse Products',
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;

  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF2563EB);
      case 'processing':
        return const Color(0xFFF59E0B);
      case 'shipped':
        return const Color(0xFF7C3AED);
      case 'delivered':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return GestureDetector(
      onTap: () => context.push('/delivery-status/${order.orderId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.base),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Order #${order.orderId}',
                            style: AppTypography.titleLarge.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pillBr,
                          ),
                          child: Text(
                            order.status.toString().toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: context.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatDate(order.orderDate),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: context.textTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

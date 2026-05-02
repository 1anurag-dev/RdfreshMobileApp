import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

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
          'Active Orders',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => context.read<OrderBloc>()..add(LoadActiveOrders()),
        child: const ActiveOrdersBody(),
      ),
    );
  }
}

class ActiveOrdersBody extends StatelessWidget {
  const ActiveOrdersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: ShimmerList(itemCount: 3, itemHeight: 100),
          );
        }

        if (state is OrderError) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Error loading orders',
            subtitle: state.message,
          );
        }

        if (state is ActiveOrdersLoaded) {
          if (state.orders.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Active Orders',
              subtitle: 'You have no orders in progress',
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () {
                    context.push('/delivery-status/${order.orderId}');
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lgBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.lgBr,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderId}',
                        style: AppTypography.titleMedium.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${order.status}',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

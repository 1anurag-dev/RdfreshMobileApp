import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rdfresh/features/home/presentation/widgets/enhanced_order_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/notification/presentation/widgets/enhanced_notification_bell.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../delivery/presentation/bloc/order_bloc.dart';
import '../../../delivery/presentation/bloc/order_event.dart';
import '../../../delivery/presentation/bloc/order_state.dart';
import '../../../delivery/domain/entities/order_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../../injection_container.dart' as di;

enum OrderStatusFilter { all, awaitingShipment, shipped, delivered }

enum SignatureStatusFilter { all, unsigned, signed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<OrderStatusFilter> _selectedOrderStatusFilters = {OrderStatusFilter.all};
  Set<SignatureStatusFilter> _selectedSignatureStatusFilters = {
    SignatureStatusFilter.all,
  };

  List<OrderEntity> _applyFilters(List<OrderEntity> orders) {
    List<OrderEntity> filteredOrders = List.from(orders);

    if (!_selectedOrderStatusFilters.contains(OrderStatusFilter.all)) {
      filteredOrders = filteredOrders.where((order) {
        final status = order.status.toLowerCase();
        return _selectedOrderStatusFilters.any((filter) {
          switch (filter) {
            case OrderStatusFilter.awaitingShipment:
              return status == 'pending' ||
                  status == 'ordered' ||
                  status == 'processing';
            case OrderStatusFilter.shipped:
              return status == 'shipped';
            case OrderStatusFilter.delivered:
              return status == 'delivered';
            default:
              return false;
          }
        });
      }).toList();
    }

    if (!_selectedSignatureStatusFilters.contains(SignatureStatusFilter.all)) {
      filteredOrders = filteredOrders.where((order) {
        final signatureStatus = order.signatureStatus?.toLowerCase() ?? '';
        return _selectedSignatureStatusFilters.any((filter) {
          switch (filter) {
            case SignatureStatusFilter.unsigned:
              return signatureStatus != 'signed';
            case SignatureStatusFilter.signed:
              return signatureStatus == 'signed';
            default:
              return false;
          }
        });
      }).toList();
    }

    return filteredOrders;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di.sl<OrderBloc>()..add(LoadActiveOrders()),
          ),
          BlocProvider(
            create: (context) => di.sl<CartBloc>()..add(LoadCart(userId)),
          ),
        ],
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: _buildAppBar(context),
              body: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async {
                  context.read<OrderBloc>().add(LoadActiveOrders());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      _buildHeroCard(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildQuickActions(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildOrdersSection(context),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: _buildAvatar(context),
        ),
      ),
      title: const SizedBox.shrink(),
      actions: [
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final totalItems = state.items.length;
            return _buildIconBadge(
              context,
              icon: Icons.shopping_bag_outlined,
              count: totalItems,
              onTap: () => context.push('/cart'),
            );
          },
        ),
        const NotificationBellIcon(),
        IconButton(
          icon: Icon(Icons.logout_rounded, color: context.textPrimary),
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'there');

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.baseBr,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_getGreeting()}, $name",
            style: AppTypography.headlineMedium.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Track your shipments and manage installations",
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final orders = state is ActiveOrdersLoaded ? state.orders : <OrderEntity>[];

        final lastOrder = orders.isNotEmpty ? orders.first : null;
        final lastOrderName = lastOrder != null
            ? 'Order #${lastOrder.orderId.length > 6 ? lastOrder.orderId.substring(lastOrder.orderId.length - 6) : lastOrder.orderId}'
            : 'No orders yet';

        int daysRemaining = 90;
        if (lastOrder != null) {
          final orderDate = DateTime.tryParse(lastOrder.orderDate);
          if (orderDate != null) {
            final daysSince = DateTime.now().difference(orderDate).inDays;
            daysRemaining = (90 - daysSince).clamp(0, 90);
          }
        }

        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        double savingsThisMonth = 0;
        for (final order in orders) {
          final orderDate = DateTime.tryParse(order.orderDate);
          if (orderDate != null && orderDate.isAfter(startOfMonth)) {
            savingsThisMonth += order.totalAmount.toDouble() * 0.15;
          }
        }

        return Row(
          children: [
            _buildValueCard(
              context,
              icon: Icons.replay_rounded,
              label: 'Reorder',
              value: lastOrder != null ? 'Last Order' : '—',
              subtitle: lastOrderName,
              onTap: () {
                if (lastOrder == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No previous orders to reorder')),
                  );
                  return;
                }
                context.push('${AppRoutes.deliveryStatus}/${lastOrder.orderId}');
              },
            ),
            _buildDaysRemainingCard(context, daysRemaining, lastOrder != null),
            _buildValueCard(
              context,
              icon: Icons.savings_outlined,
              label: 'Savings',
              value: '\$${savingsThisMonth.toStringAsFixed(0)}',
              subtitle: 'This month',
              onTap: () {},
            ),
            _buildValueCard(
              context,
              icon: Icons.help_outline_rounded,
              label: 'Help',
              value: 'FAQ',
              subtitle: '& Support',
              onTap: () => context.go(AppRoutes.support),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final seed = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email ?? 'RD Fresh');
    final initials = seed
        .split(RegExp(r'\s+|@'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
      child: Text(
        initials.isEmpty ? 'RD' : initials,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildIconBadge(
    BuildContext context, {
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon, color: context.textPrimary),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildValueCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: InkWell(
          borderRadius: AppRadius.baseBr,
          onTap: onTap,
          child: Container(
            height: 90,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
              borderRadius: AppRadius.baseBr,
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primaryGreen, size: 20),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.small.copyWith(
                    color: context.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysRemainingCard(
    BuildContext context,
    int daysRemaining,
    bool hasOrders,
  ) {
    final isUrgent = daysRemaining <= 5 && hasOrders;
    final iconColor = isUrgent ? AppColors.error : AppColors.primaryGreen;
    final bgColor = isUrgent
        ? AppColors.error.withValues(alpha: 0.06)
        : AppColors.primaryGreen.withValues(alpha: 0.06);
    final borderColor = isUrgent
        ? AppColors.error.withValues(alpha: 0.15)
        : AppColors.primaryGreen.withValues(alpha: 0.12);

    Widget card = Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.baseBr,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: iconColor, size: 20),
              const SizedBox(height: 4),
              Text(
                hasOrders ? '$daysRemaining' : '—',
                maxLines: 1,
                style: AppTypography.titleSmall.copyWith(
                  color: isUrgent ? AppColors.error : context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Days Left',
                maxLines: 1,
                style: AppTypography.small.copyWith(
                  color: context.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isUrgent) {
      card = Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Container(
            height: 90,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.baseBr,
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: iconColor, size: 20)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 800.ms,
                    )
                    .tint(color: AppColors.error.withValues(alpha: 0.3)),
                const SizedBox(height: 4),
                Text(
                  '$daysRemaining',
                  maxLines: 1,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 600.ms)
                    .then()
                    .shake(hz: 2, duration: 400.ms),
                Text(
                  'Days Left',
                  maxLines: 1,
                  style: AppTypography.small.copyWith(
                    color: AppColors.error.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return card;
  }

  Widget _buildOrdersSection(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "All Orders",
                  style: AppTypography.headlineMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(child: _buildCompactOrderStatusDropdown(context)),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: _buildCompactSignatureStatusDropdown(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const ShimmerList(itemCount: 3, itemHeight: 100);
              }

              if (state is OrderError) {
                return AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to load orders',
                  subtitle: 'Pull down to refresh and try again',
                );
              }

              if (state is ActiveOrdersLoaded) {
                if (state.orders.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: 'No Orders Found',
                    subtitle: 'Your orders will appear here.\n'
                        'Track your shipments in real-time.',
                  );
                }

                final filteredOrders = _applyFilters(state.orders);

                if (filteredOrders.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.filter_list_rounded,
                    title: 'No Orders Found',
                    subtitle: 'Try adjusting your filters',
                  );
                }

                final displayOrders = filteredOrders.take(3).toList();

                return Column(
                  children: [
                    ...displayOrders.map((order) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: EnhancedOrderCard(
                          order: order,
                          onPress: () {
                            context.push(
                              '${AppRoutes.deliveryStatus}/${order.orderId}',
                            );
                          },
                        ),
                      );
                    }),
                    if (filteredOrders.length > 3)
                      Center(
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.activeOrders),
                          child: Text(
                            'View All Orders (${filteredOrders.length})',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactOrderStatusDropdown(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: AppRadius.smBr,
        color: context.cardColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatusFilter>(
          isDense: true,
          isExpanded: true,
          hint: Text(
            'Status',
            style: AppTypography.caption.copyWith(color: context.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
          value: _selectedOrderStatusFilters.length == 1
              ? _selectedOrderStatusFilters.first
              : null,
          items: OrderStatusFilter.values.map((filter) {
            return DropdownMenuItem<OrderStatusFilter>(
              value: filter,
              child: StatefulBuilder(
                builder: (context, setState) {
                  final isSelected =
                      _selectedOrderStatusFilters.contains(filter);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() => _toggleOrderStatusFilter(filter));
                            this.setState(() {});
                          },
                          activeColor: AppColors.primaryGreen,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getOrderStatusLabel(filter),
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : context.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (OrderStatusFilter? newValue) {
            if (newValue != null) {
              setState(() => _toggleOrderStatusFilter(newValue));
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return OrderStatusFilter.values.map((filter) {
              if (_selectedOrderStatusFilters.contains(OrderStatusFilter.all)) {
                return Text(
                  'All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                );
              } else if (_selectedOrderStatusFilters.isEmpty) {
                return Text(
                  'Status',
                  style: AppTypography.caption
                      .copyWith(color: context.textTertiary),
                );
              } else {
                return Text(
                  '${_selectedOrderStatusFilters.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildCompactSignatureStatusDropdown(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: AppRadius.smBr,
        color: context.cardColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SignatureStatusFilter>(
          isDense: true,
          isExpanded: true,
          hint: Text(
            'Signature',
            style: AppTypography.caption.copyWith(color: context.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
          value: _selectedSignatureStatusFilters.length == 1
              ? _selectedSignatureStatusFilters.first
              : null,
          items: SignatureStatusFilter.values.map((filter) {
            return DropdownMenuItem<SignatureStatusFilter>(
              value: filter,
              child: StatefulBuilder(
                builder: (context, setState) {
                  final isSelected =
                      _selectedSignatureStatusFilters.contains(filter);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(
                                () => _toggleSignatureStatusFilter(filter));
                            this.setState(() {});
                          },
                          activeColor: AppColors.accent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getSignatureStatusLabel(filter),
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? AppColors.accent
                                : context.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (SignatureStatusFilter? newValue) {
            if (newValue != null) {
              setState(() => _toggleSignatureStatusFilter(newValue));
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return SignatureStatusFilter.values.map((filter) {
              if (_selectedSignatureStatusFilters
                  .contains(SignatureStatusFilter.all)) {
                return Text(
                  'All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                );
              } else if (_selectedSignatureStatusFilters.isEmpty) {
                return Text(
                  'Signature',
                  style: AppTypography.caption
                      .copyWith(color: context.textTertiary),
                );
              } else {
                return Text(
                  '${_selectedSignatureStatusFilters.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
            }).toList();
          },
        ),
      ),
    );
  }

  void _toggleOrderStatusFilter(OrderStatusFilter filter) {
    setState(() {
      if (filter == OrderStatusFilter.all) {
        _selectedOrderStatusFilters = {OrderStatusFilter.all};
      } else {
        Set<OrderStatusFilter> newFilters =
            Set.from(_selectedOrderStatusFilters);
        if (newFilters.contains(filter)) {
          newFilters.remove(filter);
        } else {
          newFilters.add(filter);
          newFilters.remove(OrderStatusFilter.all);
        }
        _selectedOrderStatusFilters =
            newFilters.isEmpty ? {OrderStatusFilter.all} : newFilters;
      }
    });
  }

  void _toggleSignatureStatusFilter(SignatureStatusFilter filter) {
    setState(() {
      if (filter == SignatureStatusFilter.all) {
        _selectedSignatureStatusFilters = {SignatureStatusFilter.all};
      } else {
        Set<SignatureStatusFilter> newFilters =
            Set.from(_selectedSignatureStatusFilters);
        if (newFilters.contains(filter)) {
          newFilters.remove(filter);
        } else {
          newFilters.add(filter);
          newFilters.remove(SignatureStatusFilter.all);
        }
        _selectedSignatureStatusFilters =
            newFilters.isEmpty ? {SignatureStatusFilter.all} : newFilters;
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Welcome back';
  }

  String _getOrderStatusLabel(OrderStatusFilter filter) {
    switch (filter) {
      case OrderStatusFilter.all:
        return 'All Orders';
      case OrderStatusFilter.awaitingShipment:
        return 'Awaiting';
      case OrderStatusFilter.shipped:
        return 'Shipped';
      case OrderStatusFilter.delivered:
        return 'Delivered';
    }
  }

  String _getSignatureStatusLabel(SignatureStatusFilter filter) {
    switch (filter) {
      case SignatureStatusFilter.all:
        return 'All';
      case SignatureStatusFilter.unsigned:
        return 'Unsigned';
      case SignatureStatusFilter.signed:
        return 'Signed';
    }
  }
}

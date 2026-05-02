// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:rdfresh/features/home/presentation/widgets/enhanced_order_card.dart';
import '../../../../core/theme/app_theme.dart';
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

    // Apply order status filter
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

    // Apply signature status filter
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
              backgroundColor: const Color(0xFFF8F9FB),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: SizedBox(
                  // kToolbarHeight is usually 56.0, setting image to ~40
                  // gives it professional breathing room.
                  height: 100,
                  child: Image.asset(
                    "assets/images/png/logo.png",
                    fit: BoxFit
                        .contain, // This ensures the logo scales without distortion
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.eco, color: AppColors.primaryGreen),
                  ),
                ),
                centerTitle: true, // Forces alignment to the center
                actions: [
                  // Cart Icon with Badge
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      final totalItems = state.items.length;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              context.push('/cart');
                            },
                          ),
                          if (totalItems > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$totalItems',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const NotificationBellIcon(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  // Refresh the active orders by reloading the OrderBloc
                  final orderBloc = context.read<OrderBloc>();
                  orderBloc.add(LoadActiveOrders());

                  // Wait for a moment to show the refresh animation
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Welcome Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Track your shipments and manage installations",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // "All Orders",
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "All Orders",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Compact Filters in Top-Right Corner
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildCompactOrderStatusDropdown(),
                                    const SizedBox(width: 8),
                                    _buildCompactSignatureStatusDropdown(),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, state) {
                                if (state is OrderLoading) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (state is OrderError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Unable to load orders',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (state is ActiveOrdersLoaded) {
                                  if (state.orders.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGreen
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.local_shipping_outlined,
                                                size: 48,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No Orders Found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Your orders will appear here',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Track your shipments in real-time',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade400,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  // Show all orders with filters applied
                                  final filteredOrders = _applyFilters(
                                    state.orders,
                                  );

                                  if (filteredOrders.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGreen
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.filter_list,
                                                size: 48,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No Orders Found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Try adjusting your filters',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: filteredOrders.map((order) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: EnhancedOrderCard(
                                          order: order,
                                          onPress: () {
                                            context.push(
                                              '${AppRoutes.deliveryStatus}/${order.orderId}',
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /*
                      // Panel Calculator Row
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickAction(
                              "Panel Calculator",
                              Icons.calculate_outlined,
                              () {
                                context.push(AppRoutes.calculator);
                              },
                              backgroundColor: AppColors.primaryGreen
                                  .withOpacity(0.1),
                              iconColor: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 20),

                      //Products & Downloads Items Row
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildQuickAction(
                              "Products",
                              Icons.inventory_2_outlined,
                              () {
                                context.push(AppRoutes.products);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildQuickAction(
                              "Downloads",
                              Icons.inventory_2_outlined,
                              () {
                                context.push('/faq');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Support FAQ's Row
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildQuickAction(
                              "Support",
                              Icons.inventory_2_outlined,
                              () {
                                context.push('/Support');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildQuickAction(
                              "FAQs",
                              Icons.inventory_2_outlined,
                              () {
                                context.push('/faq');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      */
                      const SizedBox(height: 30),
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

  Widget _buildCompactOrderStatusDropdown() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatusFilter>(
          isDense: true,
          isExpanded: false,
          hint: Text(
            'Status',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                  final isSelected = _selectedOrderStatusFilters.contains(
                    filter,
                  );
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              _toggleOrderStatusFilter(filter);
                            });
                            // Also update parent state
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
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
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
              setState(() {
                _toggleOrderStatusFilter(newValue);
              });
            }
          },
          selectedItemBuilder: (BuildContext context) {
            if (_selectedOrderStatusFilters.contains(OrderStatusFilter.all)) {
              return [
                Text(
                  'All',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 12),
                ),
              ];
            } else if (_selectedOrderStatusFilters.isEmpty) {
              return [
                Text(
                  'Status',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ];
            } else {
              return [
                Text(
                  '${_selectedOrderStatusFilters.length}',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ];
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompactSignatureStatusDropdown() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SignatureStatusFilter>(
          isDense: true,
          isExpanded: false,
          hint: Text(
            'Signature',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                  final isSelected = _selectedSignatureStatusFilters.contains(
                    filter,
                  );
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              _toggleSignatureStatusFilter(filter);
                            });
                            // Also update parent state
                            this.setState(() {});
                          },
                          activeColor: Colors.blue,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getSignatureStatusLabel(filter),
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
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
              setState(() {
                _toggleSignatureStatusFilter(newValue);
              });
            }
          },
          selectedItemBuilder: (BuildContext context) {
            if (_selectedSignatureStatusFilters.contains(
              SignatureStatusFilter.all,
            )) {
              return [
                Text('All', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ];
            } else if (_selectedSignatureStatusFilters.isEmpty) {
              return [
                Text(
                  'Signature',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ];
            } else {
              return [
                Text(
                  '${_selectedSignatureStatusFilters.length}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ];
            }
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
        Set<OrderStatusFilter> newFilters = Set.from(
          _selectedOrderStatusFilters,
        );
        if (newFilters.contains(filter)) {
          newFilters.remove(filter);
        } else {
          newFilters.add(filter);
          newFilters.remove(
            OrderStatusFilter.all,
          ); // Remove "All" when specific filters are selected
        }
        _selectedOrderStatusFilters = newFilters.isEmpty
            ? {OrderStatusFilter.all}
            : newFilters;
      }
    });
  }

  void _toggleSignatureStatusFilter(SignatureStatusFilter filter) {
    setState(() {
      if (filter == SignatureStatusFilter.all) {
        _selectedSignatureStatusFilters = {SignatureStatusFilter.all};
      } else {
        Set<SignatureStatusFilter> newFilters = Set.from(
          _selectedSignatureStatusFilters,
        );
        if (newFilters.contains(filter)) {
          newFilters.remove(filter);
        } else {
          newFilters.add(filter);
          newFilters.remove(
            SignatureStatusFilter.all,
          ); // Remove "All" when specific filters are selected
        }
        _selectedSignatureStatusFilters = newFilters.isEmpty
            ? {SignatureStatusFilter.all}
            : newFilters;
      }
    });
  }

  String _getOrderStatusLabel(OrderStatusFilter filter) {
    switch (filter) {
      case OrderStatusFilter.all:
        return 'All Orders';
      case OrderStatusFilter.awaitingShipment:
        return 'Awaiting Shipment';
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

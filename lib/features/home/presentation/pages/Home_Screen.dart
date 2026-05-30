import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../delivery/presentation/bloc/order_bloc.dart';
import '../../../delivery/presentation/bloc/order_event.dart';
import '../../../delivery/presentation/bloc/order_state.dart';
import '../../../delivery/domain/entities/order_entity.dart';
import '../../../Products/presentation/bloc/product_bloc.dart';
import '../../../Products/presentation/bloc/product_event.dart';
import '../../../Products/presentation/bloc/product_state.dart';
import '../../../Products/domain/entities/product.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/domain/entities/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/app_toast.dart';
import '../../../Products/presentation/pages/product_description_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _tips = [
    'Did you know? Ethylene gas from one rotten apple can spoil an entire produce drawer in 24 hours.',
    'Tip: Place RD Fresh packs near the evaporator fans for maximum absorption coverage.',
    'Restaurants using zeolite packs report 30-50% less food waste each month.',
    'Pro tip: Track your pack installation dates to maximize the 30-day absorption cycle.',
    'Fun fact: Zeolite minerals are 100% natural volcanic rock — safe, non-toxic, and eco-friendly.',
    'Save more: Depleted RD Fresh packs can be used as plant fertilizer in your garden.',
  ];

  late final String _todayTip;

  @override
  void initState() {
    super.initState();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    _todayTip = _tips[dayOfYear % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) context.go(AppRoutes.login);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<OrderBloc>()..add(LoadActiveOrders()),
          ),
          BlocProvider(
            create: (_) => di.sl<CartBloc>()..add(LoadCart(userId)),
          ),
          BlocProvider(
            create: (_) => di.sl<ProductBloc>()..add(LoadProducts()),
          ),
        ],
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                context.read<OrderBloc>().add(LoadActiveOrders());
                context.read<ProductBloc>().add(LoadProducts());
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildHeroCard(context),
                    const SizedBox(height: 16),
                    _buildConsultationBanner(context),
                    _buildBagChangeCard(context),
                    _buildActiveOrdersBanner(context),
                    const SizedBox(height: 24),
                    _buildQuickStats(context),
                    const SizedBox(height: 28),
                    _buildProductHighlights(context),
                    const SizedBox(height: 24),
                    _buildTipCard(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'there');
    final initials = name
        .split(RegExp(r'\s+|@'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
    } else {
      greeting = 'Welcome back';
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.primaryGreen.withValues(alpha: 0.1),
                child: AutoSizeText(
                  initials.isEmpty ? 'RD' : initials,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '$greeting, $name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    minFontSize: 14,
                  ),
                  AutoSizeText(
                    'Manage your installations',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                ],
              ),
            ),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                final count = state.items.length;
                return IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: context.textSecondary,
                        size: 24,
                      ),
                      if (count > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => context.push(AppRoutes.cart),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: context.textSecondary,
                size: 24,
              ),
              onPressed: () => context.push(AppRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final orders =
            state is ActiveOrdersLoaded ? state.orders : <OrderEntity>[];
        final lastOrder = orders.isNotEmpty ? orders.first : null;

        int daysRemaining = 30;
        if (lastOrder != null) {
          final orderDate = DateTime.tryParse(lastOrder.orderDate);
          if (orderDate != null) {
            final daysSince = DateTime.now().difference(orderDate).inDays;
            daysRemaining = (30 - daysSince).clamp(0, 30);
          }
        }

        final progress = lastOrder != null ? daysRemaining / 30.0 : 1.0;
        final statusText = lastOrder != null
            ? 'Replace in $daysRemaining days'
            : 'No active installation';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A6847), Color(0xFF064E34)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            'Active Installation',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                          const SizedBox(height: 8),
                          AutoSizeText(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            minFontSize: 16,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.products),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const AutoSizeText(
                                'Reorder Now',
                                style: TextStyle(
                                  color: Color(0xFF0A6847),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                lastOrder != null ? '$daysRemaining' : '--',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                              ),
                              AutoSizeText(
                                'days',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsultationBanner(BuildContext context) {
    final isGuest = FirebaseAuth.instance.currentUser == null;

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final orders =
            state is ActiveOrdersLoaded ? state.orders : <OrderEntity>[];

        if (!isGuest && orders.isNotEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: GestureDetector(
            onTap: _launchPhone,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_in_talk_rounded,
                    color: Colors.amber.shade800,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'New here? Get a FREE Consultation',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Talk to our team before placing your first order',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _launchPhone,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A6847),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Call Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TODO: Replace with real phone number from Mike
  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+18007337374');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildBagChangeCard(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('customerEmail', isEqualTo: email)
          .where('status', isEqualTo: 'delivered')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final unsignedOrders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['signatureStatus'] != 'signed';
        }).toList();

        if (unsignedOrders.isEmpty) return const SizedBox.shrink();

        return Column(
          children: unsignedOrders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final orderNumber = data['id'] ?? data['orderId'] ?? doc.id;
            final deliveredAt = data['deliveredAt'] as String?;
            int daysSince = 0;
            if (deliveredAt != null) {
              final delivered = DateTime.tryParse(deliveredAt);
              if (delivered != null) {
                daysSince = DateTime.now().difference(delivered).inDays;
              }
            }

            final isUrgent = daysSince >= 4;
            final bgColor = isUrgent ? AppColors.error : AppColors.warning;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: GestureDetector(
                onTap: () => context.push('${AppRoutes.bagChange}/${doc.id}'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bgColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bgColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: bgColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'Time to Change Your Bags!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                            const SizedBox(height: 4),
                            AutoSizeText(
                              daysSince > 0
                                  ? 'Order #$orderNumber delivered $daysSince day${daysSince == 1 ? '' : 's'} ago'
                                  : 'Order #$orderNumber — install your bags now',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const AutoSizeText(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActiveOrdersBanner(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is! ActiveOrdersLoaded) return const SizedBox.shrink();

        final activeOrders = state.orders
            .where((o) =>
                o.status.toLowerCase() != 'delivered' &&
                o.status.toLowerCase() != 'completed')
            .toList();

        if (activeOrders.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.activeOrders),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.info,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AutoSizeText(
                      'You have ${activeOrders.length} active order${activeOrders.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      minFontSize: 11,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final orders =
            state is ActiveOrdersLoaded ? state.orders : <OrderEntity>[];

        final totalOrders = orders.length;

        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        double savings = 0;
        for (final o in orders) {
          final d = DateTime.tryParse(o.orderDate);
          if (d != null && d.isAfter(startOfMonth)) {
            savings += o.totalAmount.toDouble() * 0.15;
          }
        }

        return SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _StatCard(
                icon: Icons.receipt_long_rounded,
                label: 'Total Orders',
                value: '$totalOrders',
                color: AppColors.info,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.savings_rounded,
                label: 'Approximate Savings This Month',
                subtitle: 'Based on estimated food waste reduction',
                value: '\$${savings.toStringAsFixed(0)}',
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, pState) {
                  final count =
                      pState is ProductLoaded ? pState.products.length : 0;
                  return _StatCard(
                    icon: Icons.eco_rounded,
                    label: 'Products Active',
                    value: '$count',
                    color: AppColors.primaryGreen,
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductHighlights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  'Our Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  minFontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.products),
                child: const Text(
                  'See All →',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }
              if (state is ProductLoaded && state.products.isNotEmpty) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) =>
                      _ProductMiniCard(product: state.products[i]),
                );
              }
              return Center(
                child: Text(
                  'No products available',
                  style: TextStyle(color: context.textSecondary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AutoSizeText(
                    'Tip of the Day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B3A2D),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _todayTip,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF1B3A2D).withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          AutoSizeText(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
            maxLines: 1,
            minFontSize: 14,
          ),
          AutoSizeText(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            minFontSize: 8,
          ),
          if (subtitle != null)
            AutoSizeText(
              subtitle!,
              style: TextStyle(
                fontSize: 8,
                color: context.textSecondary.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              minFontSize: 6,
            ),
        ],
      ),
    );
  }
}

class _ProductMiniCard extends StatelessWidget {
  final Product product;

  const _ProductMiniCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<CartBloc>()..add(LoadCart(userId)),
            child: ProductDescriptionPage(product: product),
          ),
        ),
      ),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
          boxShadow: context.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.primaryGreen.withValues(alpha: 0.08),
                          child: const Icon(Icons.eco_rounded,
                              color: AppColors.primaryGreen, size: 32),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryGreen.withValues(alpha: 0.08),
                          child: const Icon(Icons.eco_rounded,
                              color: AppColors.primaryGreen, size: 32),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                        child: const Icon(Icons.eco_rounded,
                            color: AppColors.primaryGreen, size: 32),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        product.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        maxLines: 2,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                            maxLines: 1,
                            minFontSize: 11,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final currentUser = FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Sign In Required'),
                                  content: const Text('Please sign in or create an account to add items to your cart.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        context.go(AppRoutes.login);
                                      },
                                      child: const Text('Sign In'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            context.read<CartBloc>().add(
                                  AddProductToCart(
                                    CartItem(
                                      productId: product.id,
                                      sku: product.sku,
                                      name: product.name,
                                      price: product.price,
                                      imageUrl: product.imageUrl,
                                    ),
                                    userId,
                                  ),
                                );
                            AppToast.show(context, message: '${product.name} added to cart');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


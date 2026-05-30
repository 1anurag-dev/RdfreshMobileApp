import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../domain/entities/product.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'product_description_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Walk-in Coolers',
    'Produce',
    'Dairy',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<ProductBloc>()..add(LoadProducts()),
        ),
        BlocProvider(
          create: (_) => di.sl<CartBloc>()
            ..add(LoadCart(FirebaseAuth.instance.currentUser?.uid ?? '')),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          'Products',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          minFontSize: 20,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: context.inputFillColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: context.textTertiary,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.textTertiary,
                        ),
                        suffixIcon: Icon(
                          Icons.tune_rounded,
                          color: context.textTertiary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : context.inputFillColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AutoSizeText(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : context.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const ShimmerList(
                          itemCount: 4,
                          itemHeight: 110,
                        );
                      }

                      if (state is ProductError) {
                        return AppEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load products',
                          subtitle: 'Pull down to refresh',
                        );
                      }

                      if (state is ProductLoaded) {
                        var products = state.products;

                        if (_selectedCategory != 'All') {
                          final catLower = _selectedCategory.toLowerCase();
                          products = products.where((p) {
                            if (p.category.isNotEmpty) {
                              return p.category.toLowerCase() == catLower;
                            }
                            final combined =
                                '${p.name} ${p.description}'.toLowerCase();
                            return combined.contains(catLower);
                          }).toList();
                        }

                        if (_searchQuery.isNotEmpty) {
                          final query = _searchQuery.toLowerCase();
                          products = products
                              .where((p) =>
                                  p.name.toLowerCase().contains(query) ||
                                  p.description.toLowerCase().contains(query))
                              .toList();
                        }

                        if (products.isEmpty) {
                          return AppEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No products found',
                            subtitle: 'Try a different search',
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<ProductBloc>()
                                .add(LoadProducts());
                            await Future.delayed(
                                const Duration(milliseconds: 400));
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              return _ProductListCard(
                                product: products[i],
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  final Product product;

  const _ProductListCard({required this.product});

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: context.borderColor.withValues(alpha: 0.3)),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.08),
                          child: const Icon(Icons.eco_rounded,
                              color: AppColors.primaryGreen, size: 28),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.08),
                          child: const Icon(Icons.eco_rounded,
                              color: AppColors.primaryGreen, size: 28),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                        child: const Icon(Icons.eco_rounded,
                            color: AppColors.primaryGreen, size: 28),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  AutoSizeText(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                    maxLines: 1,
                    minFontSize: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

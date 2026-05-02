import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import 'product_description_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Walk-In',
    'Reach-In',
    'Cooler',
  ];

  List<Product> _filterProducts(List<Product> products) {
    if (_selectedFilter == 'All') return products;
    final name = _selectedFilter.toLowerCase();
    return products.where((p) {
      final n = p.name.toLowerCase();
      switch (name) {
        case 'walk-in':
          return n.contains('walk-in') ||
              n.contains('protein') ||
              n.contains('dairy') ||
              n.contains('produce');
        case 'reach-in':
          return n.contains('reach-in') || n.contains('produce');
        case 'cooler':
          return n.contains('cooler') || n.contains('all in one');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider(create: (_) => di.sl<CartBloc>()..add(LoadCart(userId))),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Products',
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.pagePaddingH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Professional atmosphere control solutions for commercial refrigeration.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.pagePaddingH,
                itemCount: _filters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedFilter = filter),
                    backgroundColor: context.surfaceColor,
                    selectedColor: AppColors.accent.withValues(alpha: 0.15),
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : context.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : context.borderColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillBr,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, productState) {
                  if (productState is ProductLoading) {
                    return const ShimmerGrid(itemCount: 4, crossAxisCount: 2);
                  } else if (productState is ProductError) {
                    return AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Error',
                      subtitle: productState.message,
                    );
                  } else if (productState is ProductLoaded) {
                    final filtered = _filterProducts(productState.products);
                    if (filtered.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: _selectedFilter == 'All'
                            ? 'No Products'
                            : 'No $_selectedFilter Products',
                        subtitle: _selectedFilter == 'All'
                            ? 'Products will appear here when available.'
                            : 'Try selecting a different filter.',
                      );
                    }
                    return BlocConsumer<CartBloc, CartState>(
                      listener: (context, cartState) {
                        if (cartState.status == CartStatus.failure &&
                            cartState.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cart Error: ${cartState.errorMessage}',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      builder: (context, cartState) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: Responsive.gridChildAspectRatio(context),
                            crossAxisSpacing: AppSpacing.base,
                            mainAxisSpacing: AppSpacing.base,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final product = filtered[index];
                            final quantity = cartState.getQuantity(product.id);

                            return GestureDetector(
                              onTap: () {
                                final cartBloc = context.read<CartBloc>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (routeContext) =>
                                        ProductDescriptionPage(
                                      product: product,
                                      onAddToCart: () {
                                        if (userId.isEmpty) {
                                          ScaffoldMessenger.of(routeContext)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please login to add to cart',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        cartBloc.add(
                                          AddProductToCart(
                                            CartItem(
                                              productId: product.id,
                                              sku: product.sku,
                                              name: product.name,
                                              price: product.price,
                                              imageUrl: product.imageUrl,
                                              quantity: 1,
                                            ),
                                            userId,
                                          ),
                                        );
                                        ScaffoldMessenger.of(routeContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${product.name} Added To Cart',
                                            ),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor:
                                                AppColors.primaryGreen,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: ProductCard(
                                product: product,
                                quantity: quantity,
                                onAddToCart: () {
                                  if (userId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please login to add to cart',
                                        ),
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
                                            quantity: 1,
                                          ),
                                          userId,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} Added To Cart',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.primaryGreen,
                                    ),
                                  );
                                },
                                onIncrement: () {
                                  context.read<CartBloc>().add(
                                        UpdateQuantity(
                                          product.id,
                                          quantity + 1,
                                          userId,
                                        ),
                                      );
                                },
                                onDecrement: () {
                                  context.read<CartBloc>().add(
                                        UpdateQuantity(
                                          product.id,
                                          quantity - 1,
                                          userId,
                                        ),
                                      );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

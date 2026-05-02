import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Cart',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 3, itemHeight: 100),
            );
          }

          if (state.status == CartStatus.failure) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Failed to load cart',
              subtitle: state.errorMessage ?? 'Please try again',
            );
          }

          if (state.items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add products to get started',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Dismissible(
                        key: ValueKey(item.productId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppRadius.baseBr,
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => context.read<CartBloc>().add(
                              UpdateQuantity(item.productId, 0, userId),
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: AppRadius.baseBr,
                            border: Border.all(color: context.borderColor),
                            boxShadow: context.cardShadow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.mdBr,
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: context.shimmerBase,
                                    highlightColor: context.shimmerHighlight,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: context.shimmerBase,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: context.inputFillColor,
                                      borderRadius: AppRadius.mdBr,
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: context.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: AppTypography.priceSmall.copyWith(
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen
                                                .withValues(alpha: 0.08),
                                            borderRadius: AppRadius.mdBr,
                                          ),
                                          child: Row(
                                            children: [
                                              _buildQtyButton(
                                                context,
                                                Icons.remove,
                                                () {
                                                  context
                                                      .read<CartBloc>()
                                                      .add(
                                                        UpdateQuantity(
                                                          item.productId,
                                                          item.quantity - 1,
                                                          userId,
                                                        ),
                                                      );
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.base,
                                                ),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: AppTypography
                                                      .titleMedium
                                                      .copyWith(
                                                    color: context.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              _buildQtyButton(
                                                context,
                                                Icons.add,
                                                () {
                                                  context
                                                      .read<CartBloc>()
                                                      .add(
                                                        UpdateQuantity(
                                                          item.productId,
                                                          item.quantity + 1,
                                                          userId,
                                                        ),
                                                      );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            context.read<CartBloc>().add(
                                                  UpdateQuantity(
                                                    item.productId,
                                                    0,
                                                    userId,
                                                  ),
                                                );
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom Total & Checkout
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTypography.headlineMedium.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${state.totalAmount.toStringAsFixed(2)}',
                            style: AppTypography.price.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.mdBr,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdBr),
                            ),
                            onPressed: () => context.push('/checkout'),
                            child: Text(
                              'PROCEED TO CHECKOUT',
                              style: AppTypography.button
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQtyButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBr,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.primaryGreen),
        ),
      ),
    );
  }
}

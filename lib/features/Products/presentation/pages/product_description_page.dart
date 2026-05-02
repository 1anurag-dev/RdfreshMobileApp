import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../domain/entities/product.dart';

class ProductDescriptionPage extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDescriptionPage({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: BackButton(color: context.textPrimary),
        title: Text(
          product.name,
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient fade
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: context.shimmerBase,
                      highlightColor: context.shimmerHighlight,
                      child: Container(color: context.shimmerBase),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: context.inputFillColor,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 64,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        text: 'SKU: ${product.sku}',
                        backgroundColor:
                            AppColors.primaryGreen.withValues(alpha: 0.1),
                        textColor: AppColors.primaryGreen,
                      ),
                      if (product.isAvailable) AppBadge.success('In Stock'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    product.name,
                    style: AppTypography.displaySmall.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: AppTypography.price.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // How It Works
                  Text(
                    'How It Works',
                    style: AppTypography.titleLarge.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _buildHowItWorks(context),
                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    'About this product',
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    product.description.isEmpty
                        ? 'Walk-In Refrigeration Filters Replacement'
                        : product.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: context.surfaceColor,
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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.mdBr,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
                ),
                onPressed: onAddToCart,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                label: Text(
                  'Add to Cart',
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      _HowItWorksStep(
        icon: Icons.inventory_2_outlined,
        label: 'Place',
        description: 'Inside cooler',
      ),
      _HowItWorksStep(
        icon: Icons.air_outlined,
        label: 'Absorb',
        description: 'Ethylene gas',
      ),
      _HowItWorksStep(
        icon: Icons.eco_outlined,
        label: 'Preserve',
        description: 'Fresh produce',
      ),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Center(
              child: Container(
                height: 1,
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
          );
        }
        final step = steps[index ~/ 2];
        return Expanded(
          flex: 2,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child:
                    Icon(step.icon, color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                step.label,
                style: AppTypography.titleSmall.copyWith(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                step.description,
                style: AppTypography.small.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _HowItWorksStep {
  final IconData icon;
  final String label;
  final String description;

  const _HowItWorksStep({
    required this.icon,
    required this.label,
    required this.description,
  });
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ProductCard({
    super.key,
    required this.product,
    this.quantity = 0,
    required this.onAddToCart,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: AppRadius.baseBr,
            border: Border.all(color: context.borderColor),
            boxShadow: context.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.base),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
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
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          product.name,
                          style: AppTypography.titleMedium.copyWith(
                            color: context.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'SKU: ${product.sku}',
                        style: AppTypography.small.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTypography.priceSmall.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: TextButton(
                          onPressed: onAddToCart,
                          style: TextButton.styleFrom(
                            backgroundColor:
                                AppColors.primaryGreen.withValues(alpha: 0.08),
                            foregroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdBr,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'ADD TO CART',
                            style: AppTypography.buttonSmall.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (quantity > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: AppRadius.pillBr,
                boxShadow: AppShadows.sm,
              ),
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

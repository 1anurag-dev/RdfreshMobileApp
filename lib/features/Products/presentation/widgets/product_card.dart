import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            if (onAddToCart != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAddToCart,
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
          ],
        ),
      ),
    );
  }
}

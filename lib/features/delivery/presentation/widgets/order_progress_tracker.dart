import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

/// Amazon-style horizontal order tracker.
///
/// Four stages: Confirmed -> On the Way -> Delivered -> Installed.
/// `status` drives stages 0-2 (processing/shipped/delivered) and `isSigned`
/// flips the final "Installed" stage. Fully responsive: labels shrink and wrap
/// instead of overflowing on small screens.
class OrderProgressTracker extends StatelessWidget {
  final String status;
  final bool isSigned;

  const OrderProgressTracker({
    super.key,
    required this.status,
    this.isSigned = false,
  });

  static const List<String> _labels = [
    'Confirmed',
    'On the Way',
    'Delivered',
    'Installed',
  ];

  static const List<IconData> _icons = [
    Icons.receipt_long_rounded,
    Icons.local_shipping_rounded,
    Icons.inventory_2_rounded,
    Icons.verified_rounded,
  ];

  int get _progressIndex {
    if (isSigned) return 3;
    switch (status.toLowerCase()) {
      case 'delivered':
        return 2;
      case 'shipped':
        return 1;
      default:
        return 0; // pending / processing / unknown
    }
  }

  String get _headline {
    switch (_progressIndex) {
      case 3:
        return 'Installed — your cycle is active!';
      case 2:
        return 'Delivered — confirm installation';
      case 1:
        return 'Your order is on the way!';
      default:
        return 'Your order is confirmed!';
    }
  }

  String get _subline {
    switch (_progressIndex) {
      case 3:
        return "We'll remind you when it's time to change your bags.";
      case 2:
        return 'Place the bags in your cooler, then sign to start your 30 days.';
      case 1:
        return "We'll let you know the moment it arrives.";
      default:
        return "We're preparing your order for shipment.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressIndex;
    const double nodeD = 34.0;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic headline
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icons[progress],
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headline,
                      style: AppTypography.titleMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subline,
                      style: AppTypography.caption.copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Horizontal stepper
          LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final double seg = w / 4;
              final double firstCenter = seg / 2;
              final double filledWidth = progress * seg;

              return SizedBox(
                height: nodeD + 32,
                child: Stack(
                  children: [
                    // Background connector line (node-center to node-center)
                    Positioned(
                      left: firstCenter,
                      top: nodeD / 2 - 1.5,
                      child: Container(
                        width: w - seg,
                        height: 3,
                        decoration: BoxDecoration(
                          color: context.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Filled (green) portion up to current stage
                    Positioned(
                      left: firstCenter,
                      top: nodeD / 2 - 1.5,
                      child: Container(
                        width: filledWidth,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Nodes + labels
                    Row(
                      children: List.generate(4, (i) {
                        final bool done = i < progress;
                        final bool current = i == progress;
                        return SizedBox(
                          width: seg,
                          child: Column(
                            children: [
                              _node(
                                context,
                                i,
                                done: done,
                                current: current,
                                size: nodeD,
                              ),
                              const SizedBox(height: 6),
                              AutoSizeText(
                                _labels[i],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                minFontSize: 8,
                                style: AppTypography.labelSmall.copyWith(
                                  color: (done || current)
                                      ? context.textPrimary
                                      : context.textTertiary,
                                  fontWeight: current
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _node(
    BuildContext context,
    int i, {
    required bool done,
    required bool current,
    required double size,
  }) {
    final bool active = done || current;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGreen : context.inputFillColor,
        shape: BoxShape.circle,
        border: current
            ? Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.30),
                width: 3,
              )
            : null,
        boxShadow: current
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.30),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Icon(
        done ? Icons.check_rounded : _icons[i],
        color: active ? Colors.white : context.textTertiary,
        size: 18,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class DeliveryConfirmedScreen extends StatefulWidget {
  final String orderId;
  final int? rating;
  final String? feedback;

  const DeliveryConfirmedScreen({
    super.key,
    required this.orderId,
    this.rating,
    this.feedback,
  });

  @override
  State<DeliveryConfirmedScreen> createState() =>
      _DeliveryConfirmedScreenState();
}

class _DeliveryConfirmedScreenState extends State<DeliveryConfirmedScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Section
                      Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 60,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Delivery Successful!',
                            style: AppTypography.headlineLarge.copyWith(
                              color: context.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: AppRadius.pillBr,
                            ),
                            child: Text(
                              'Order #${widget.orderId}',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),

                          // Summary Cards
                          _buildSummaryCard(
                            context,
                            icon: Icons.draw,
                            iconColor: AppColors.success,
                            bgColor: AppColors.successBg,
                            title: 'Signature Captured',
                            subtitle: 'Delivery confirmed with signature',
                          ),

                          if (widget.rating != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _buildRatingCard(context),
                          ],

                          if (widget.feedback != null &&
                              widget.feedback!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _buildFeedbackCard(context),
                          ],
                        ],
                      ),

                      // Bottom Section
                      Column(
                        children: [
                          const SizedBox(height: AppSpacing.xxxl),
                          Text(
                            'Thank you for using RD Fresh',
                            style: AppTypography.bodyLarge.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
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
                                onPressed: () => context.go(AppRoutes.home),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.mdBr,
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.home_rounded, size: 20),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Back to Home',
                                      style: AppTypography.button
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildRatingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.mdBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating: ${widget.rating}/5',
                  style: AppTypography.titleSmall.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < widget.rating! ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.mdBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.comment, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback Provided',
                  style: AppTypography.titleSmall.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${widget.feedback}"',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/signature_pad_widget.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/order_progress_tracker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/app_toast.dart';

class DeliveryStatusScreen extends StatefulWidget {
  final String orderId;

  const DeliveryStatusScreen({super.key, required this.orderId});

  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen>
    with TickerProviderStateMixin {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 0;
  String _signatureData = '';
  bool _hasSignature = false;
  bool _isMarkingReceived = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onSignatureChanged(String signature) {
    setState(() {
      _signatureData = signature;
      _hasSignature = signature.isNotEmpty;
    });
  }

  void _onRatingChanged(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  void _onCompleteDelivery(BuildContext blocContext) {
    if (_hasSignature) {
      final orderBloc = blocContext.read<OrderBloc>();

      _scaleController.forward().then((_) {
        _fadeController.reverse().then((_) {
          orderBloc.add(
            CompleteOrder(
              orderId: widget.orderId,
              signature: _signatureData,
              rating: _rating > 0 ? _rating : null,
              feedback: _feedbackController.text.trim().isNotEmpty
                  ? _feedbackController.text.trim()
                  : null,
            ),
          );
        });
      });
    }
  }

  // Customer confirms the package physically arrived. This advances the order
  // to "delivered" and reveals the installation sign-off. We rely on this tap
  // (rather than a ShipStation "delivered" event, which the legacy API does not
  // reliably emit) so the flow works for both carrier and hand-delivery.
  Future<void> _onMarkReceived(BuildContext blocContext) async {
    if (_isMarkingReceived) return;
    final orderBloc = blocContext.read<OrderBloc>();
    setState(() => _isMarkingReceived = true);
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': 'delivered',
        'deliveredAt': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      orderBloc.add(LoadOrderDetails(widget.orderId));
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Could not update. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingReceived = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order Details',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            di.sl<OrderBloc>()..add(LoadOrderDetails(widget.orderId)),
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderCompleted) {
              final queryParams = <String, String>{'orderId': widget.orderId};

              if (_rating > 0) {
                queryParams['rating'] = _rating.toString();
              }

              if (_feedbackController.text.trim().isNotEmpty) {
                queryParams['feedback'] = _feedbackController.text.trim();
              }

              final uri = Uri(
                path: AppRoutes.deliveryConfirmed,
                queryParameters: queryParams,
              );

              context.push(uri.toString());
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return _buildLoadingState();
            }

            if (state is OrderError) {
              return _buildErrorState(state.message);
            }

            if (state is OrderDetailsLoaded) {
              return AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: DeliveryStatusBody(
                        order: state.order,
                        signatureData: _signatureData,
                        hasSignature: _hasSignature,
                        rating: _rating,
                        feedbackController: _feedbackController,
                        onSignatureChanged: _onSignatureChanged,
                        onRatingChanged: _onRatingChanged,
                        onCompleteDelivery: () => _onCompleteDelivery(context),
                        onMarkReceived: () => _onMarkReceived(context),
                        isMarkingReceived: _isMarkingReceived,
                        isLoading: state is OrderCompletionLoading,
                        orderId: widget.orderId,
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.base),
      child: ShimmerList(itemCount: 4, itemHeight: 120),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Unable to Load Order',
              style: AppTypography.headlineSmall.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    final orderBloc = context.read<OrderBloc>();
                    orderBloc.add(LoadOrderDetails(widget.orderId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smBr,
                    ),
                  ),
                  child: const Text('Try Again'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryStatusBody extends StatelessWidget {
  final dynamic order;
  final String signatureData;
  final bool hasSignature;
  final int rating;
  final TextEditingController feedbackController;
  final Function(String) onSignatureChanged;
  final Function(int) onRatingChanged;
  final VoidCallback onCompleteDelivery;
  final VoidCallback onMarkReceived;
  final bool isMarkingReceived;
  final bool isLoading;
  final String orderId;

  const DeliveryStatusBody({
    super.key,
    required this.order,
    required this.signatureData,
    required this.hasSignature,
    required this.rating,
    required this.feedbackController,
    required this.onSignatureChanged,
    required this.onRatingChanged,
    required this.onCompleteDelivery,
    required this.onMarkReceived,
    required this.isMarkingReceived,
    required this.isLoading,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status.toString().toLowerCase();
    final isSigned = order.signatureStatus == 'signed';
    final isShipped = status == 'shipped';
    final isDelivered = status == 'delivered';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderProgressTracker(
            status: order.status.toString(),
            isSigned: isSigned,
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSection(
            context,
            title: 'Shipping Address',
            child: AddressCard(address: order.shipTo),
          ),
          const SizedBox(height: AppSpacing.xl),

          ..._buildActionArea(
            context,
            isSigned: isSigned,
            isShipped: isShipped,
            isDelivered: isDelivered,
          ),
        ],
      ),
    );
  }

  // The action area changes based on where the order is in its journey, so the
  // sign-off can NEVER be reached before the customer has the bags in hand.
  List<Widget> _buildActionArea(
    BuildContext context, {
    required bool isSigned,
    required bool isShipped,
    required bool isDelivered,
  }) {
    // 4) Installed — cycle is running.
    if (isSigned) {
      return [_buildInstalledCard(context)];
    }

    // 3) Delivered (arrived) but not yet installed — the ONLY state that
    //    exposes the signature sign-off.
    if (isDelivered) {
      return [
        _buildInfoBanner(
          context,
          icon: Icons.inventory_2_rounded,
          color: AppColors.success,
          text:
              'Your bags have arrived! Place them in your walk-in cooler, then sign below to start your 30-day cycle.',
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildSection(
          context,
          title: 'Confirm Installation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign below to confirm you installed the new bags.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SignaturePadWidget(
                onSignatureChanged: onSignatureChanged,
                isEnabled: !isLoading,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildFeedbackSection(context),
        const SizedBox(height: AppSpacing.xxl),
        _buildConfirmButton(context),
      ];
    }

    // 2) On the way — let the customer mark it received once it lands.
    if (isShipped) {
      return [
        _buildInfoBanner(
          context,
          icon: Icons.local_shipping_rounded,
          color: AppColors.info,
          text:
              "Your order is on the way! Tap the button below once it arrives so you can confirm installation.",
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildReceivedButton(context),
      ];
    }

    // 1) Processing — nothing to sign yet.
    return [
      _buildInfoBanner(
        context,
        icon: Icons.inventory_2_outlined,
        color: AppColors.info,
        text:
            "We're getting your order ready. You'll get a notification the moment it ships.",
      ),
    ];
  }

  Widget _buildInfoBanner(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBr,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimary,
                height: 1.4,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstalledCard(BuildContext context) {
    final next = _nextChangeText();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBr,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Installation confirmed!',
                  style: AppTypography.titleMedium.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your 30-day cycle is now active.${next.isNotEmpty ? '\n$next' : ''}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Delivery Feedback',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate your delivery experience',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: StarRatingWidget(
              initialRating: rating,
              onRatingChanged: onRatingChanged,
              isEnabled: !isLoading,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          TextField(
            controller: feedbackController,
            enabled: !isLoading,
            maxLines: 3,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Additional feedback (optional)',
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdBr,
                borderSide: BorderSide(color: context.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdBr,
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdBr,
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: !isMarkingReceived ? AppColors.primaryGradient : null,
          color: isMarkingReceived ? context.borderColor : null,
          borderRadius: AppRadius.mdBr,
          boxShadow: !isMarkingReceived
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: isMarkingReceived ? null : onMarkReceived,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
            elevation: 0,
          ),
          child: isMarkingReceived
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_rounded, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        "I've received my order",
                        style: AppTypography.button.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: hasSignature && !isLoading ? AppColors.primaryGradient : null,
        color: hasSignature && !isLoading ? null : context.borderColor,
        borderRadius: AppRadius.mdBr,
        boxShadow: hasSignature && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: (hasSignature && !isLoading) ? onCompleteDelivery : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.normal,
          child: isLoading
              ? _buildLoadingButtonContent()
              : _buildNormalButtonContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingButtonContent() {
    return SizedBox(
      key: const ValueKey('loading'),
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.white.withValues(alpha: 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Confirming...',
              style: AppTypography.button.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalButtonContent() {
    return Row(
      key: const ValueKey('normal'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Confirm Installation',
            style: AppTypography.button.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _nextChangeText() {
    final signedAt = order.signedAt;
    if (signedAt == null) return '';
    final d = DateTime.tryParse(signedAt.toString());
    if (d == null) return '';
    final next = d.add(const Duration(days: 30));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Next bag change around ${months[next.month - 1]} ${next.day}, ${next.year}.';
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class AddressCard extends StatelessWidget {
  final dynamic address;

  const AddressCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            address.name,
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimary,
            ),
            maxLines: 2,
            minFontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${address.street1}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${address.city}, ${address.state}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            address.phone,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

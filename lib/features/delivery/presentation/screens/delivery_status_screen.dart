import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/signature_pad_widget.dart';
import '../widgets/star_rating_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

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
          'Order ${widget.orderId}',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
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
                        isLoading: state is OrderCompletionLoading,
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
  final bool isLoading;

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
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            title: 'Shipping Address',
            child: AddressCard(address: order.shipTo),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSection(
            context,
            title: 'Order Status',
            child: StatusCard(status: order.status),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSection(
            context,
            title: 'Customer Signature',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please sign below to confirm delivery',
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

          _buildSection(
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
          ),
          const SizedBox(height: AppSpacing.xxl),

          AnimatedContainer(
            duration: AppDurations.normal,
            curve: Curves.easeInOut,
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: hasSignature && !isLoading
                  ? AppColors.primaryGradient
                  : null,
              color: hasSignature && !isLoading
                  ? null
                  : context.borderColor,
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
              onPressed: (hasSignature && !isLoading)
                  ? onCompleteDelivery
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBr,
                ),
                elevation: 0,
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.normal,
                child: isLoading
                    ? _buildLoadingButtonContent()
                    : _buildNormalButtonContent(),
              ),
            ),
          ),
        ],
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
              'Completing...',
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
        Text(
          'Complete Delivery',
          style: AppTypography.button.copyWith(color: Colors.white),
        ),
      ],
    );
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
          Text(
            address.name,
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${address.street1}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${address.city}, ${address.state}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.phone,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case 'processing':
        statusColor = AppColors.info;
        statusText = 'Processing';
        break;
      case 'shipped':
        statusColor = AppColors.accent;
        statusText = 'Shipped';
        break;
      case 'delivered':
        statusColor = AppColors.success;
        statusText = 'Delivered';
        break;
      default:
        statusColor = context.textTertiary;
        statusText = status;
    }

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
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(status), color: statusColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: AppTypography.caption.copyWith(
                    color: context.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTypography.titleMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'processing':
        return Icons.inventory_2;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}

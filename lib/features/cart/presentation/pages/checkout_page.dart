import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/bloc/checkout_order_bloc.dart';
import '../../../orders/presentation/bloc/checkout_order_event.dart';
import '../../../orders/presentation/bloc/checkout_order_state.dart';
import '../../data/models/cart_item_model.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      final parts = (user.displayName ?? '').split(' ');
      if (parts.isNotEmpty) _firstNameController.text = parts.first;
      if (parts.length > 1) _lastNameController.text = parts.sublist(1).join(' ');
    }
    _stateController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Complete your order',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Billing Information Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: AppRadius.baseBr,
                  border: Border.all(color: context.borderColor),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billing Information',
                      style: AppTypography.headlineMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const Gap.xxl(),
                    // First Name & Last Name Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'First Name',
                            controller: _firstNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: _buildTextField(
                            label: 'Last Name',
                            controller: _lastNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap.xl(),
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const Gap.xl(),
                    _buildTextField(
                      label: 'Phone',
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const Gap.xl(),
                    _buildTextField(
                      label: 'Address',
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    const Gap.xl(),
                    // City, State, ZIP Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'City',
                            controller: _cityController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: _buildTextField(
                            label: 'State',
                            controller: _stateController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'State is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: _buildTextField(
                            label: 'ZIP',
                            controller: _zipController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'ZIP code is required';
                              }
                              final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
                              if (!zipRegex.hasMatch(value)) {
                                return 'Enter a valid ZIP code';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap.xl(),
              // Order Summary Section
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  final subtotal = state.totalAmount;
                  final stateText = _stateController.text.trim().toLowerCase();
                  final isVirginia =
                      stateText == 'virginia' || stateText == 'va';
                  final tax = isVirginia ? (subtotal * 0.053) : 0.0;
                  final total = subtotal + tax;

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: AppRadius.baseBr,
                      border: Border.all(color: context.borderColor),
                      boxShadow: context.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: AppTypography.headlineMedium.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                        const Gap.xl(),
                        // Cart Items
                        ...state.items.map((item) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.base),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.smBr,
                                  child: CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: context.shimmerBase,
                                      highlightColor: context.shimmerHighlight,
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: context.shimmerBase,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 50,
                                      height: 50,
                                      color: context.inputFillColor,
                                      child: Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 24,
                                        color: context.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style:
                                            AppTypography.titleSmall.copyWith(
                                          color: context.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${item.quantity}',
                                        style:
                                            AppTypography.caption.copyWith(
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Gap.xl(),
                        Divider(color: context.dividerColor),
                        const Gap.base(),
                        // Subtotal
                        _buildSummaryRow(
                          'Subtotal',
                          '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Tax
                        if (isVirginia) ...[
                          _buildSummaryRow(
                            'Tax (5.3%)',
                            '\$${tax.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        // Shipping
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'FREE',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Gap.xl(),
                        Divider(color: context.dividerColor),
                        const Gap.base(),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTypography.headlineSmall.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: AppTypography.price.copyWith(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const Gap.xxl(),
                        // Complete Order Button
                        BlocConsumer<CheckoutOrderBloc, CheckoutOrderState>(
                          listener: (context, checkoutState) {
                            if (checkoutState is CheckoutOrderSuccess) {
                              final userId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (userId != null) {
                                context.read<CartBloc>().add(
                                  ClearCartEvent(userId),
                                );
                              }

                              AppToast.show(context, message: 'Order completed successfully!');
                              context.go(AppRoutes.home);
                            } else if (checkoutState is CheckoutOrderError) {
                              AppToast.show(context, message: 'Unable to complete your order. Please check your connection and try again.', type: ToastType.error);
                            }
                          },
                          builder: (context, checkoutState) {
                            final isLoading =
                                checkoutState is CheckoutOrderLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: isLoading
                                      ? null
                                      : AppColors.primaryGradient,
                                  color: isLoading
                                      ? AppColors.primaryGreen
                                          .withValues(alpha: 0.6)
                                      : null,
                                  borderRadius: AppRadius.mdBr,
                                  boxShadow: isLoading
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.primaryGreen
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final currentUser = FirebaseAuth.instance.currentUser;
                                          if (currentUser != null && !currentUser.emailVerified) {
                                            _showEmailVerificationDialog(context);
                                            return;
                                          }
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final randomId = const Uuid().v4();

                                            final order = CheckoutOrderModel(
                                              id: randomId,
                                              userId: FirebaseAuth.instance
                                                      .currentUser?.uid ??
                                                  '',
                                              items: state.items
                                                  .map(
                                                    (item) =>
                                                        (item as CartItemModel),
                                                  )
                                                  .toList(),
                                              billingInfo:
                                                  CheckoutBillingInfoModel(
                                                firstName:
                                                    _firstNameController.text
                                                        .trim(),
                                                lastName: _lastNameController
                                                    .text
                                                    .trim(),
                                                email: _emailController.text
                                                    .trim(),
                                                phone: _phoneController.text
                                                    .trim(),
                                                address: _addressController.text
                                                    .trim(),
                                                city: _cityController.text
                                                    .trim(),
                                                state: _stateController.text
                                                    .trim(),
                                                zip: _zipController.text.trim(),
                                              ),
                                              subtotal: subtotal,
                                              tax: tax,
                                              total: total,
                                              status: 'pending',
                                              createdAt: DateTime.now(),
                                            );

                                            context
                                                .read<CheckoutOrderBloc>()
                                                .add(
                                                  CreateOrderEvent(order),
                                                );
                                          } else {
                                            AppToast.show(context, message: 'Please fill in all required fields correctly', type: ToastType.error);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.mdBr,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor:
                                              Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          child: Text(
                                            'Processing...',
                                            style: AppTypography.button
                                                .copyWith(color: Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Complete Order',
                                          style: AppTypography.button
                                              .copyWith(color: Colors.white),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showEmailVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Email Not Verified',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Please verify your email before placing orders. Check your inbox for a verification link.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                if (mounted) {
                  AppToast.show(context, message: 'Verification email sent');
                }
              } catch (_) {
                if (mounted) {
                  AppToast.show(context, message: 'Failed to send email', type: ToastType.error);
                }
              }
            },
            child: const Text(
              'Resend Email',
              style: TextStyle(
                color: Color(0xFF0A6847),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            constraints: const BoxConstraints(minHeight: 56),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

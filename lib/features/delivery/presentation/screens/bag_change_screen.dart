import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../widgets/signature_pad_widget.dart';

class BagChangeScreen extends StatefulWidget {
  final String orderId;

  const BagChangeScreen({super.key, required this.orderId});

  @override
  State<BagChangeScreen> createState() => _BagChangeScreenState();
}

class _BagChangeScreenState extends State<BagChangeScreen> {
  String _signatureData = '';
  bool _hasSignature = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _orderData = doc.data();
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSignatureChanged(String signature) {
    setState(() {
      _signatureData = signature;
      _hasSignature = signature.isNotEmpty;
    });
  }

  Future<void> _submitBagChange() async {
    if (!_hasSignature || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'signatureStatus': 'signed',
        'signatureImage': _signatureData,
        'signedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 20),
              Text(
                'Bag Change Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your next replacement will be in 30 days.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        AppToast.show(context,
            message: 'Failed to submit. Please try again.',
            type: ToastType.error);
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber =
        _orderData?['id'] ?? _orderData?['orderId'] ?? widget.orderId;

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
          'Confirm Bag Change',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A6847), Color(0xFF064E34)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_rounded,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AutoSizeText(
                                'Order #$orderNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                minFontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (_orderData?['deliveredAt'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Delivered: ${_formatDate(_orderData!['deliveredAt'])}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.info, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sign below to confirm you have installed the new RD Fresh bags in your walk-in cooler.',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Signature',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SignaturePadWidget(
                    onSignatureChanged: _onSignatureChanged,
                    isEnabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _hasSignature && !_isSubmitting
                            ? AppColors.primaryGradient
                            : null,
                        color: _hasSignature && !_isSubmitting
                            ? null
                            : context.borderColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _hasSignature && !_isSubmitting
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton(
                        onPressed: (_hasSignature && !_isSubmitting)
                            ? _submitBagChange
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Confirm Bag Change',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

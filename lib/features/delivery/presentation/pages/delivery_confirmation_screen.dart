import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/check_list_item.dart';
import '../widgets/info_card.dart';

class DeliveryConfirmationScreen extends StatefulWidget {
  const DeliveryConfirmationScreen({super.key});

  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.primaryNavy,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: context.textPrimary),
        title: Image.asset("assets/images/png/rd_fresh.png", height: 40),
        centerTitle: true,
        backgroundColor: context.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const InfoCard(
              title: "Delivery Confirmation",
              details: {
                "Order ID": "#RD-2026-402",
                "Package Type": "Fresh Produce Box",
                "Delivery Date": "Jan 30, 2026",
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            const InfoCard(
              title: "Delivery Location",
              icon: Icons.location_on_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Green Valley Restaurant",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "1234 Main Street, Suite 100\nChicago, IL 60601",
                    style: TextStyle(color: AppColors.textGrey, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const InfoCard(
              title: "Package Contents",
              content: Column(
                children: [
                  ChecklistItem(label: "Fresh vegetables received"),
                  ChecklistItem(label: "Packaging in good condition"),
                  ChecklistItem(label: "Temperature verified"),
                  ChecklistItem(label: "All items accounted for"),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSignatureSection(),
            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_signatureController.isNotEmpty) {
                    // Trigger BLoC event here
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBr,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Confirm Delivery",
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Signature Pad",
                style: AppTypography.headlineSmall.copyWith(
                  color: context.textPrimary,
                ),
              ),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _signatureController.clear();
                  },
                  icon: Icon(
                    Icons.refresh,
                    size: 14,
                    color: context.textPrimary,
                  ),
                  label: Text(
                    "Clear",
                    style: AppTypography.caption.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.borderColor, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBr,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Please sign below to confirm receipt of your package",
            style: AppTypography.caption.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: context.borderColor),
              borderRadius: AppRadius.lgBr,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.lgBr,
              child: Signature(
                controller: _signatureController,
                height: 200,
                backgroundColor: context.inputFillColor,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                "Draw your signature above",
                style: AppTypography.caption.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

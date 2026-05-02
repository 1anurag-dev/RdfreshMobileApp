import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/need_help.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: BackButton(
          color: context.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Customer Support",
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupportBottomSheet(context),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.md),
            NeedHelpCard(),
            SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _showSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contact Support",
                style: AppTypography.headlineMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSupportTile(
                context,
                icon: Icons.phone_outlined,
                title: "Call Support",
                subtitle: "Speak with our team directly",
                onTap: () async {
                  final Uri phoneUri =
                      Uri(scheme: 'tel', path: '(580) FRESH4U');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSupportTile(
                context,
                icon: Icons.email_outlined,
                title: "Email Support",
                subtitle: "Support@rdfresh.com",
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'Support@rdfresh.com',
                    queryParameters: {'subject': 'Support Request - RD Fresh App'},
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: AppRadius.baseBr,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          border: Border.all(color: context.borderColor),
          borderRadius: AppRadius.baseBr,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

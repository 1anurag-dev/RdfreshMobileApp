import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

class NeedHelpCard extends StatelessWidget {
  const NeedHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Need More Help?",
            style: AppTypography.headlineMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Our Support team is here to assist you with any questions or concerns.",
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildContactTile(
            context,
            icon: Icons.phone_outlined,
            title: "Call Support",
            subtitle: "(580) FRESH4U",
            onTap: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: '(580) FRESH4U');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildContactTile(
            context,
            icon: Icons.email_outlined,
            title: "Email Support",
            subtitle: "Support@rdfresh.com",
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'Support@rdfresh.com',
                queryParameters: {'subject': 'Support:Request-RDFreshApp'},
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildContactTile(
            context,
            icon: Icons.quiz_outlined,
            title: "View FAQs",
            subtitle: "Common questions answered",
            onTap: () => context.push('/faq'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: context.inputFillColor,
          borderRadius: AppRadius.baseBr,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.base),
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
          ],
        ),
      ),
    );
  }
}

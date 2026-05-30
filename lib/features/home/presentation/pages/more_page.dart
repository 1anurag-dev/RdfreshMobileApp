import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'More',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            'Resources and account tools for your team.',
            style: AppTypography.bodyLarge.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildMoreTile(
            context,
            title: 'Downloads',
            subtitle: 'Access product manuals and documentation',
            icon: Icons.download_outlined,
            onTap: () => context.push(AppRoutes.downloads),
          ),
          const SizedBox(height: AppSpacing.base),
          _buildMoreTile(
            context,
            title: 'Customer Support & FAQs',
            subtitle: 'Get in touch with our help center',
            icon: Icons.headset_mic_outlined,
            onTap: () => context.push(AppRoutes.support),
          ),
          const SizedBox(height: AppSpacing.base),
          _buildMoreTile(
            context,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            icon: Icons.delete_forever_rounded,
            onTap: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.baseBr,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: AppRadius.baseBr,
          border: Border.all(color: context.borderColor),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdBr,
              ),
              child: Icon(icon, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: AppSpacing.lg),
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
                  const SizedBox(height: AppSpacing.xs),
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
              size: 16,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

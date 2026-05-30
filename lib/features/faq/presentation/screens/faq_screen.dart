import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Support/presentation/widgets/video_card.dart';
import '../bloc/faq_bloc.dart';
import '../bloc/faq_state.dart';

import '../widgets/faq_cards.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "FAQs & Videos",
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<FaqBloc, FaqState>(
        builder: (context, state) {
          if (state is FaqLoading) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: ShimmerList(itemCount: 5, itemHeight: 80),
            );
          }
          if (state is FaqError) return Center(child: Text(state.message));

          if (state is FaqLoaded) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                ...state.faqs
                    .map((faq) =>
                        FaqCard(question: faq.question, answer: faq.answer))
                    .toList(),
                const SizedBox(height: AppSpacing.xl),

                // Video Library
                AppSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Video Library",
                        style: AppTypography.headlineMedium.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Learn how to maintain and optimize your equipment",
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                const VideoLibraryCard(
                  title: "RD FRESH VIDEO",
                  videoUrl:
                      "https://youtu.be/BGc7Vll5jQE?si=CeayckQcSCOloJd5",
                ),
                const SizedBox(height: AppSpacing.md),
                const VideoLibraryCard(
                  title: "RD FRESH INSTALLATION VIDEO",
                  videoUrl:
                      "https://youtu.be/u1ca6RnhqyE?si=EU1ODTERnykJbQ_0",
                ),
                const SizedBox(height: AppSpacing.md),
                const VideoLibraryCard(
                  title: "RD FRESH MAINTENANCE",
                  videoUrl:
                      "https://youtu.be/2Q_cg1GrbMM?si=osz0JPqgQBSCHzxC",
                ),

                const SizedBox(height: AppSpacing.xl),
                _buildSupportFooter(context, context.pop),
                const SizedBox(height: 100),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Frequently Asked\nQuestions',
            style: AppTypography.displaySmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find answers to common questions about RD Fresh',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportFooter(BuildContext context, VoidCallback onPress) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.lgBr,
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Still need help?',
            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Our support team is ready to assist you with any questions',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBr,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Contact Support',
                style: AppTypography.button.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

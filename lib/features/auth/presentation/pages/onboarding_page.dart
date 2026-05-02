import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      if (FirebaseAuth.instance.currentUser != null) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  final List<OnboardingContent> _content = [
    const OnboardingContent(
      icon: Icons.eco_outlined,
      eyebrow: 'Protect Your Investment',
      title: 'Extend Shelf Life\nby 50%',
      body:
          'Our zeolite mineral technology absorbs ethylene gas, keeping your produce fresh longer.',
    ),
    const OnboardingContent(
      icon: Icons.local_shipping_outlined,
      eyebrow: 'Track Every Delivery',
      title: 'Real-Time Order\nTracking',
      body:
          'Know exactly when your shipments arrive and manage installations effortlessly.',
    ),
    const OnboardingContent(
      icon: Icons.notifications_active_outlined,
      eyebrow: 'Never Miss a Replacement',
      title: 'Smart Replacement\nReminders',
      body:
          'Automated 5-day notification cycle ensures your team always installs fresh packs on time.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _content.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildPage(_content[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: AppTypography.labelLarge.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _content.length,
                          (index) => _buildDot(index == _currentPage),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 56),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent item) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            decoration: BoxDecoration(
              gradient: AppColors.splashGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                topRight: Radius.circular(AppRadius.xxl),
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: context.elevatedShadow,
            ),
            child: Icon(item.icon, size: 100, color: Colors.white),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 36, 30, 0),
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              child: Column(
                key: ValueKey(item.title),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.eyebrow,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.displayMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    item.body,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen
            : AppColors.accent.withValues(alpha: 0.3),
        borderRadius: AppRadius.pillBr,
      ),
    );
  }

  Widget _buildNextButton() {
    bool isLast = _currentPage == _content.length - 1;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppRadius.mdBr,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
            elevation: 0,
          ),
          onPressed: () {
            if (isLast) {
              _completeOnboarding();
            } else {
              _pageController.nextPage(
                duration: AppDurations.slow,
                curve: Curves.easeInOut,
              );
            }
          },
          child: Text(
            isLast ? 'GET STARTED' : 'NEXT',
            style: AppTypography.button.copyWith(color: Colors.white),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class OnboardingContent {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;

  const OnboardingContent({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });
}

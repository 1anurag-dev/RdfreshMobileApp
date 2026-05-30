import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
      icon: Icons.restaurant_rounded,
      title: 'Food Benefits',
      bullets: [
        'Increases Shelf Life up to 50%',
        'Reduces Humidity & Odors',
        'Reduces Spread of Bacteria',
        'Reduces Cross Contamination',
      ],
    ),
    _SlideData(
      imageUrl:
          'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?auto=format&fit=crop&w=800&q=80',
      icon: Icons.settings_rounded,
      title: 'Equipment Benefits',
      bullets: [
        'Reduces Temp 3 to 5 Degrees',
        'Reduces Refrigeration Cycles',
        'Reduces Energy Costs',
        'Extends Life of Compressor',
      ],
    ),
    _SlideData(
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80',
      icon: Icons.public_rounded,
      title: 'Environmental Benefits',
      bullets: [
        'Reduces Greenhouse Gases',
        'Reduces Water Consumption',
        'Reduces Energy Usage',
        'Reduces Landfill Demands',
      ],
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _BenefitSlide(data: _slides[index]);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: isLastPage
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: i == _currentPage ? 28 : 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? Colors.white
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLastPage) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0A6847),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: AutoSizeText(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String imageUrl;
  final IconData icon;
  final String title;
  final List<String> bullets;

  const _SlideData({
    required this.imageUrl,
    required this.icon,
    required this.title,
    required this.bullets,
  });
}

class _BenefitSlide extends StatelessWidget {
  final _SlideData data;

  const _BenefitSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: data.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: const Color(0xFF0A6847),
          ),
          errorWidget: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF064E34), Color(0xFF0A6847), Color(0xFF1B3A2D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A6847).withValues(alpha: 0.55),
                const Color(0xFF0A6847).withValues(alpha: 0.70),
                const Color(0xFF1B3A2D).withValues(alpha: 0.90),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    data.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                AutoSizeText(
                  data.title,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  minFontSize: 28,
                ),
                const SizedBox(height: 36),
                ...data.bullets.map((bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Color(0xFF34D399),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              bullet,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

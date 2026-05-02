import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    OnboardingContent(
      imagePath: 'assets/images/png/rd_fresh.png',
      title: "18 Years of Trusted Expertise",
      subtitle: "",
      points: [
        "Our goal is to help you eliminate costly moisture issues, prevent cross-contamination, and rescue wilting, browning produce before it goes to waste and help you save time and money.",
      ],
      justifyPoints: false,
      color: AppColors.primaryGreen,
    ),
    OnboardingContent(
      icon: Icons.workspace_premium_outlined,
      title: "Key Benefits",
      subtitle: "",
      points: [
        "Absorbs up to 55% of its weight in humidity",
        "Increases the shelf life of food up to 50%",
        "Reduces the transfer of food odors",
        "Reduces the spread of bacteria and cross contamination",
        "Reduces refrigeration temperatures 3-5 degrees",
        "Reduces refrigeration cycles extending the life of the compressor up to 40%",
        "Reduces refrigeration costs by up to 15%",
        "Plus, it SAVES YOU MONEY and HELPS SAVE OUR ENVIRONMENT!!!",
      ],
      color: AppColors.primaryGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip', style: TextStyle(color: Colors.grey)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _content.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_content[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _content.length,
                      (index) => _buildDot(index == _currentPage),
                    ),
                  ),
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
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.imagePath != null) ...[
                Image.asset(item.imagePath!, height: 100, fit: BoxFit.contain),
                const SizedBox(height: 40),
              ] else if (item.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 60, color: item.color),
                ),
                const SizedBox(height: 40),
              ],
              if (item.title != null && item.title!.isNotEmpty) ...[
                Text(
                  item.title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
              ],
              if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                Text(
                  item.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
              ],
              ...item.points.map(
                (point) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle,
                          color: item.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          point,
                          textAlign: item.justifyPoints == true
                              ? TextAlign.justify
                              : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNextButton() {
    bool isLast = _currentPage == _content.length - 1;
    return ElevatedButton(
      onPressed: () {
        if (isLast) {
          _completeOnboarding();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        isLast ? 'Get Started' : 'Next',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String? imagePath;
  final String? title;
  final String? subtitle;
  final List<String> points;
  final bool? justifyPoints;
  final IconData? icon;
  final Color color;

  OnboardingContent({
    this.imagePath,
    this.title,
    this.subtitle,
    this.points = const [],
    this.justifyPoints = false,
    this.icon,
    this.color = Colors.green,
  });
}

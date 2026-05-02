import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool? _hasSeenOnboarding;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slightly faster fade
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward().then((_) {
      _animationCompleted = true;
      _checkNavigationReady();
    });

    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      });
      _checkNavigationReady();
    }
  }

  void _checkNavigationReady() {
    // We wait for checking Onboarding logic + short fade animation to complete
    if (_hasSeenOnboarding != null && _animationCompleted) {
      _navigate(context.read<AuthBloc>().state);
    }
  }

  void _navigate(AuthState state) {
    if (_hasSeenOnboarding == false) {
      context.go(AppRoutes.onboarding);
      return;
    }

    if (state is Authenticated) {
      context.go(AppRoutes.home);
    } else if (state is Unauthenticated) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (_hasSeenOnboarding != null && _animationCompleted) {
          _navigate(state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/images/png/rd_fresh.png',
                    width: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
              const Positioned(
                bottom: 50, // 50 pixels from the bottom edge
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

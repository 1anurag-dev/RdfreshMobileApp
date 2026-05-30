import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
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
  late Animation<double> _scaleAnimation;
  bool? _hasSeenOnboarding;
  bool _animationCompleted = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.splash,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
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
    if (_hasSeenOnboarding != null && _animationCompleted) {
      _navigate(context.read<AuthBloc>().state);
    }
  }

  void _navigate(AuthState state) {
    if (_hasNavigated) return;

    String? targetRoute;
    if (_hasSeenOnboarding == false) {
      targetRoute = AppRoutes.onboarding;
    } else if (state is Authenticated) {
      targetRoute = AppRoutes.home;
    } else if (state is Unauthenticated) {
      targetRoute = AppRoutes.login;
    }

    if (targetRoute == null) return;

    _hasNavigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(targetRoute!);
      }
    });
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
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/walkin_cooler.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.splashGradient,
                  ),
                ),
              ),
              Container(
                color: const Color(0xFF0A6847).withValues(alpha: 0.75),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/png/rdlogo.png',
                    width: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.eco_rounded,
                      size: 84,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 44,
                left: 0,
                right: 0,
                child: Text(
                  'Powered by RD Fresh',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

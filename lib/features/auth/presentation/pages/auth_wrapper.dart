import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    });
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
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (_hasSeenOnboarding != null) {
          _navigate(state);
        }
      },
      builder: (context, state) {
        if (_hasSeenOnboarding != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigate(state);
          });
        }

        return Scaffold(
          backgroundColor: context.surfaceColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/png/rd_fresh.png',
                  width: 250,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Image.asset(
                  'assets/images/png/rd_fresh.png',
                  width: 120,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

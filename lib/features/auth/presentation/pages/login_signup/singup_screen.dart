import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/auth_input_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _signUpKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_signUpKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        } else if (state is Authenticated) {
          _showSuccessDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.surfaceColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Gradient header with logo
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 32,
                    bottom: 52,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.splashGradient,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/png/rdlogo.png',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.eco_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // White form section overlapping gradient
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: context.cardShadow,
                    ),
                    child: Form(
                      key: _signUpKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: AppTypography.displaySmall.copyWith(
                              color: context.textPrimary,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.05, end: 0, duration: 400.ms),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Set up your commercial account for RD Fresh operations.',
                            style: AppTypography.bodyLarge.copyWith(
                              color: context.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.xxl),
                          AuthInput(
                            label: 'Full Name',
                            hint: 'Enter your name',
                            icon: Icons.person_outline,
                            inputType: AuthInputType.name,
                            controller: _nameController,
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.lg),
                          AuthInput(
                            label: 'Email Address',
                            hint: 'operations@restaurant.com',
                            icon: Icons.email_outlined,
                            inputType: AuthInputType.email,
                            controller: _emailController,
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.lg),
                          AuthInput(
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            inputType: AuthInputType.password,
                            controller: _passwordController,
                          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.lg),
                          AuthInput(
                            label: 'Confirm Password',
                            hint: '••••••••',
                            icon: Icons.lock_reset_outlined,
                            isPassword: true,
                            inputType: AuthInputType.password,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm Password is required';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.xxxl),
                          if (state is AuthLoading)
                            SizedBox(
                              height: 56,
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: AppRadius.mdBr,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            CustomButton(
                              text: 'CREATE ACCOUNT',
                              onPressed: _onSignUpPressed,
                            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.login),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomDialog(),
    ).then((_) {
      if (mounted) context.go(AppRoutes.home);
    });
  }
}

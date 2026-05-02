import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/auth_input_field.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogContext.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.baseBr),
          title: Text(
            'Reset Password',
            style: AppTypography.headlineSmall.copyWith(
              color: dialogContext.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: AppTypography.bodyMedium.copyWith(
                  color: dialogContext.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'operations@restaurant.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  color: dialogContext.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email address'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent! Check your inbox.',
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? 'Failed to send reset email'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Send Reset Link',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
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
          context.go(AppRoutes.home);
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
                    top: MediaQuery.of(context).padding.top + 40,
                    bottom: 60,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.splashGradient,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/png/rdlogo.png',
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.eco_rounded,
                        size: 72,
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
                      boxShadow: AppShadows.soft,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: AppTypography.displaySmall.copyWith(
                              color: context.textPrimary,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.05, end: 0, duration: 400.ms),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Sign in to track shipments and manage installations.',
                            style: AppTypography.bodyLarge.copyWith(
                              color: context.textSecondary,
                            ),
                          ).animate().fadeIn(
                              delay: 100.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.xxxl),
                          AuthInput(
                            label: 'Email Address',
                            hint: 'operations@restaurant.com',
                            icon: Icons.email_outlined,
                            inputType: AuthInputType.email,
                            controller: _emailController,
                          ).animate().fadeIn(
                              delay: 200.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.xl),
                          AuthInput(
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            inputType: AuthInputType.password,
                            controller: _passwordController,
                          ).animate().fadeIn(
                              delay: 300.ms, duration: 400.ms),
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
                              text: 'SIGN IN',
                              onPressed: _onLoginPressed,
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.md),
                          Center(
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context),
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.signup),
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
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
}

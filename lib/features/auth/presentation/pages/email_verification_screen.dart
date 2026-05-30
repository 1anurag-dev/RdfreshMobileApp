import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_toast.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        AppToast.show(context, message: 'Verification email sent');
        _startCooldown();
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, message: 'Failed to send email. Try again later.', type: ToastType.error);
      }
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (verified) {
        if (mounted) {
          AppToast.show(context, message: 'Email verified!');
          context.go(AppRoutes.home);
        }
      } else {
        if (mounted) {
          AppToast.show(context, message: 'Email not yet verified. Please check your inbox.', type: ToastType.error);
        }
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, message: 'Unable to check verification status.', type: ToastType.error);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A6847).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 40,
                  color: Color(0xFF0A6847),
                ),
              ),
              const SizedBox(height: 32),
              const AutoSizeText(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B3A2D),
                ),
                maxLines: 1,
                minFontSize: 20,
              ),
              const SizedBox(height: 12),
              Text(
                'We\'ve sent a verification link to',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              AutoSizeText(
                email,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A6847),
                ),
                maxLines: 1,
                minFontSize: 11,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your inbox and tap the link to verify.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A6847), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const AutoSizeText(
                            'I\'ve Verified',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _resendCooldown > 0 ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _resendCooldown > 0
                          ? Colors.grey.shade300
                          : const Color(0xFF0A6847),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AutoSizeText(
                    _resendCooldown > 0
                        ? 'Resend Email (${_resendCooldown}s)'
                        : 'Resend Email',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _resendCooldown > 0
                          ? Colors.grey.shade400
                          : const Color(0xFF0A6847),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

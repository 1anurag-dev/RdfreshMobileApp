import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RD Fresh Privacy Policy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: May 2026',
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(height: 24),
              ..._sections.map((s) => _SectionWidget(title: s.title, body: s.body)),
              const SizedBox(height: 24),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you have questions about this Privacy Policy, please contact us at:\n\n'
                'RD Fresh\n'
                'Email: support@rdfresh.com\n'
                'Website: www.rdfresh.com',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

const _sections = [
  _Section(
    'Information We Collect',
    'We collect information you provide directly to us, including:\n\n'
        '• Name and email address when you create an account\n'
        '• Shipping address and phone number for order fulfillment\n'
        '• Order history and product preferences\n'
        '• Device information and app usage data through Firebase Analytics',
  ),
  _Section(
    'How We Use Your Information',
    'We use the information we collect to:\n\n'
        '• Process and fulfill your orders\n'
        '• Send order confirmations, shipping updates, and delivery notifications\n'
        '• Provide replacement reminders for RD Fresh packs\n'
        '• Improve our products and services\n'
        '• Communicate with you about your account',
  ),
  _Section(
    'Data Storage & Security',
    'Your data is stored securely using Google Firebase infrastructure. '
        'We implement industry-standard security measures to protect your personal information. '
        'Your password is encrypted and never stored in plain text.',
  ),
  _Section(
    'Third-Party Services',
    'We use the following third-party services:\n\n'
        '• Firebase (Authentication, Cloud Firestore, Cloud Messaging) — for app functionality\n'
        '• ShipStation — for order fulfillment and delivery tracking\n\n'
        'These services have their own privacy policies governing the use of your information.',
  ),
  _Section(
    'Data Retention & Deletion',
    'We retain your data for as long as your account is active. '
        'You can request deletion of your account and all associated data at any time through the app\'s Settings page. '
        'Upon deletion, your data will be permanently removed from our systems.',
  ),
  _Section(
    'Your Rights',
    'You have the right to:\n\n'
        '• Access your personal data\n'
        '• Update or correct your information\n'
        '• Delete your account and all associated data\n'
        '• Opt out of marketing communications',
  ),
];

class _SectionWidget extends StatelessWidget {
  final String title;
  final String body;
  const _SectionWidget({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

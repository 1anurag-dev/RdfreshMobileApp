import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
          'Terms of Service',
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
                'RD Fresh Terms of Service',
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
                'If you have questions about these Terms of Service, please contact us at:\n\n'
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
    'Acceptance of Terms',
    'By creating an account or using the RD Fresh mobile application, you agree to be bound by these Terms of Service. '
        'If you do not agree to these terms, please do not use the application.',
  ),
  _Section(
    'Account Terms',
    '• You must provide accurate and complete information when creating an account.\n'
        '• You are responsible for maintaining the security of your account credentials.\n'
        '• You must be at least 18 years old to create an account.\n'
        '• One person or business entity may not maintain more than one account.\n'
        '• You are responsible for all activity that occurs under your account.',
  ),
  _Section(
    'Orders & Payments',
    '• All orders placed through the app are subject to acceptance and availability.\n'
        '• Prices are subject to change without notice.\n'
        '• Payment is due at the time of order placement.\n'
        '• We reserve the right to refuse or cancel any order.\n'
        '• Shipping costs and estimated delivery times are provided at checkout.',
  ),
  _Section(
    'Product Information',
    'RD Fresh products are natural zeolite mineral packs designed for use in commercial refrigeration. '
        'While we strive to provide accurate product descriptions and performance data, '
        'actual results may vary depending on usage conditions, temperature, and other environmental factors.',
  ),
  _Section(
    'Limitation of Liability',
    'RD Fresh shall not be liable for any indirect, incidental, special, consequential, or punitive damages '
        'resulting from your use of the application or our products. Our total liability shall not exceed '
        'the amount you paid for the products giving rise to the claim.',
  ),
  _Section(
    'Intellectual Property',
    'All content in the RD Fresh application, including text, graphics, logos, and software, '
        'is the property of RD Fresh and is protected by applicable intellectual property laws. '
        'You may not reproduce, distribute, or create derivative works without our express permission.',
  ),
  _Section(
    'Termination',
    'We reserve the right to suspend or terminate your account at any time for violation of these terms. '
        'You may delete your account at any time through the app\'s Settings page.',
  ),
  _Section(
    'Governing Law',
    'These Terms of Service shall be governed by and construed in accordance with the laws of the Commonwealth of Virginia, '
        'without regard to its conflict of law provisions.',
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

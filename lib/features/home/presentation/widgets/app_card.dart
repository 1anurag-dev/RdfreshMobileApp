import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lgBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: child,
    );
  }
}

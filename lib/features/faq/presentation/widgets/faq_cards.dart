import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FaqCard extends StatefulWidget {
  final String question;
  final String answer;

  const FaqCard({super.key, required this.question, required this.answer});

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lgBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBr,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              title: Text(
                widget.question,
                style: AppTypography.titleMedium.copyWith(
                  color: _isExpanded
                      ? AppColors.primaryGreen
                      : context.textPrimary,
                ),
              ),
              trailing: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: _isExpanded
                    ? AppColors.primaryGreen
                    : context.textTertiary,
              ),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  Divider(
                    height: 1,
                    color: context.dividerColor,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.base,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: Text(
                      widget.answer,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: AppDurations.fast,
            ),
          ],
        ),
      ),
    );
  }
}

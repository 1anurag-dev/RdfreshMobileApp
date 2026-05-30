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
                    child: _FormattedAnswer(answer: widget.answer),
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

class _FormattedAnswer extends StatelessWidget {
  final String answer;
  const _FormattedAnswer({required this.answer});

  @override
  Widget build(BuildContext context) {
    final paragraphs = answer.split(RegExp(r'\n\s*\n'));

    if (paragraphs.length <= 1) {
      final lines = answer.split('\n');
      if (lines.length <= 1) {
        return Text(
          answer,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            height: 1.5,
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.asMap().entries.map((entry) {
          final line = entry.value.trim();
          if (line.isEmpty) return const SizedBox(height: 12);
          final isNumbered = RegExp(r'^\d+[\.\)]').hasMatch(line);
          return Padding(
            padding: EdgeInsets.only(top: entry.key == 0 ? 0 : (isNumbered ? 8 : 12)),
            child: Text(
              line,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(top: entry.key == 0 ? 0 : 16),
          child: Text(
            entry.value.trim(),
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}

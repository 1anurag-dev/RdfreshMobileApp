import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatusStepper extends StatelessWidget {
  final List<String> statuses;
  final int currentIndex;

  const StatusStepper({
    super.key,
    required this.statuses,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(statuses.length, (index) {
        bool isLast = index == statuses.length - 1;
        bool isPassed = index <= currentIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isPassed ? Icons.check_circle : Icons.circle_outlined,
                  color: isPassed
                      ? AppColors.primaryGreen
                      : context.textTertiary,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isPassed
                        ? AppColors.primaryGreen
                        : context.borderColor,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  statuses[index],
                  style: (index == currentIndex
                          ? AppTypography.titleMedium
                          : AppTypography.bodyMedium)
                      .copyWith(
                    color: isPassed
                        ? context.textPrimary
                        : context.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

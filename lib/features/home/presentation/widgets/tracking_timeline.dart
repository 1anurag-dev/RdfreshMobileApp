import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../../../../core/theme/app_theme.dart';

class TrackingTimeline extends StatelessWidget {
  final List<String> statuses;
  final int currentStep;

  const TrackingTimeline({
    super.key,
    required this.statuses,
    this.currentStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        color: context.borderColor,
        indicatorTheme: const IndicatorThemeData(size: 15.0),
        connectorTheme: const ConnectorThemeData(thickness: 2.0),
      ),
      builder: TimelineTileBuilder.connected(
        indicatorBuilder: (context, index) {
          return index <= currentStep
              ? const DotIndicator(color: AppColors.primaryGreen)
              : DotIndicator(color: context.borderColor);
        },
        connectorBuilder: (context, index, type) {
          return SolidLineConnector(
            color: index < currentStep
                ? AppColors.primaryGreen
                : context.borderColor,
          );
        },
        contentsBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            statuses[index],
            style: (index <= currentStep
                    ? AppTypography.titleMedium
                    : AppTypography.bodyMedium)
                .copyWith(
              color: index <= currentStep
                  ? context.textPrimary
                  : context.textTertiary,
            ),
          ),
        ),
        itemCount: statuses.length,
      ),
    );
  }
}

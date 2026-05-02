import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme_new.dart';

/// Responsive utility for the app
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int gridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 4;
    if (width >= 768) return 3;
    return 2;
  }

  static double gridChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 768) return 0.7;
    return 0.62;
  }
}

/// A themed surface container (replaces ad-hoc Container + BoxDecoration)
class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadow;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.border,
    this.shadow,
    this.gradient,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? AppRadius.lg;
    final widget = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.cardColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(br),
        border: border ??
            Border.all(
              color: context.borderColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
        boxShadow: shadow ?? context.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }
    return widget;
  }
}

/// Themed Badge / Pill
class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  factory AppBadge.success(String text) => AppBadge(
        text: text,
        backgroundColor: AppColors.successBg,
        textColor: AppColors.success,
        icon: Icons.check_circle_rounded,
      );

  factory AppBadge.warning(String text) => AppBadge(
        text: text,
        backgroundColor: AppColors.warningBg,
        textColor: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      );

  factory AppBadge.error(String text) => AppBadge(
        text: text,
        backgroundColor: AppColors.errorBg,
        textColor: AppColors.error,
        icon: Icons.error_rounded,
      );

  factory AppBadge.info(String text) => AppBadge(
        text: text,
        backgroundColor: AppColors.infoBg,
        textColor: AppColors.info,
        icon: Icons.info_rounded,
      );

  factory AppBadge.accent(String text) => AppBadge(
        text: text,
        backgroundColor: AppColors.accentBg,
        textColor: AppColors.accentDark,
        icon: Icons.eco_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.primaryColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.pillBr,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor ?? context.primaryColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: textColor ?? context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gap widget - cleaner than SizedBox
class Gap extends StatelessWidget {
  final double size;

  const Gap(this.size, {super.key});
  const Gap.xs({super.key}) : size = AppSpacing.xs;
  const Gap.sm({super.key}) : size = AppSpacing.sm;
  const Gap.md({super.key}) : size = AppSpacing.md;
  const Gap.base({super.key}) : size = AppSpacing.base;
  const Gap.lg({super.key}) : size = AppSpacing.lg;
  const Gap.xl({super.key}) : size = AppSpacing.xl;
  const Gap.xxl({super.key}) : size = AppSpacing.xxl;

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}

/// Section Header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSmall
                    .copyWith(color: context.textPrimary),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall
                      .copyWith(color: context.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionText!),
          ),
      ],
    );
  }
}

/// Empty state widget
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.08),
                borderRadius: AppRadius.lgBr,
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, size: 36, color: context.primaryColor),
            ),
            const Gap.xl(),
            Text(
              title,
              style: AppTypography.headlineSmall
                  .copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            const Gap.sm(),
            Text(
              subtitle,
              style: AppTypography.bodyMedium
                  .copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionText != null) ...[
              const Gap.xl(),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder — uses the shimmer package
class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Pre-built shimmer list placeholder for loading states
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: Column(
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: context.shimmerBase,
                borderRadius: AppRadius.baseBr,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Pre-built shimmer grid placeholder for loading states
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const ShimmerGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.60,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.base),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: AppSpacing.base,
          mainAxisSpacing: AppSpacing.base,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: context.shimmerBase,
              borderRadius: AppRadius.baseBr,
            ),
          );
        },
      ),
    );
  }
}

/// Reusable gradient header with rounded bottom corners
class AppGradientHeader extends StatelessWidget {
  final Gradient gradient;
  final double? height;
  final Widget child;
  final double bottomRadius;

  const AppGradientHeader({
    super.key,
    required this.gradient,
    required this.child,
    this.height,
    this.bottomRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomRadius),
          bottomRight: Radius.circular(bottomRadius),
        ),
      ),
      child: child,
    );
  }
}

/// Status chip with tinted background
class AppStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillBr,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

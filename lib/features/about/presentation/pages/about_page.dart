import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroSection()),
          // Videos — the main attraction, right after hero
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(child: _VideosSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            sliver: SliverToBoxAdapter(child: _WhatItDoesSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            sliver: SliverToBoxAdapter(child: _TheNumbersSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            sliver: SliverToBoxAdapter(child: _TheProblemSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            sliver: SliverToBoxAdapter(child: _BeforeAfterSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            sliver: SliverToBoxAdapter(child: _ValueChainSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            sliver: SliverToBoxAdapter(child: _ESGSection()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ─── Hero Section ───
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 32, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF064E34), Color(0xFF0A6847), Color(0xFF1B3A2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // RD Fresh leaf-circle logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.eco_rounded,
                    color: Colors.white.withValues(alpha: 0.3), size: 44),
                const Icon(Icons.eco_rounded, color: Colors.white, size: 34),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.1),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            AppStrings.aboutHeroBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Videos Section — Featured, prominent ───
class _VideosSection extends StatelessWidget {
  static const _videos = [
    _VideoMeta(
      AppStrings.videoOverviewTitle,
      AppStrings.videoOverviewUrl,
      Icons.play_circle_filled_rounded,
      [Color(0xFF0A6847), Color(0xFF059669)],
      'See what RD Fresh does',
    ),
    _VideoMeta(
      AppStrings.videoInstallationTitle,
      AppStrings.videoInstallationUrl,
      Icons.build_circle_rounded,
      [Color(0xFF1B3A2D), Color(0xFF0A6847)],
      'Step-by-step setup',
    ),
    _VideoMeta(
      AppStrings.videoMaintenanceTitle,
      AppStrings.videoMaintenanceUrl,
      Icons.autorenew_rounded,
      [Color(0xFF064E34), Color(0xFF15865E)],
      '30-day replacement guide',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBr,
              ),
              child: const Icon(Icons.videocam_rounded,
                  color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.videosTitle,
                    style: AppTypography.headlineSmall.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    'Tap any video to watch',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ..._videos.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FeaturedVideoCard(meta: v),
            )),
      ],
    );
  }
}

class _VideoMeta {
  final String title;
  final String url;
  final IconData icon;
  final List<Color> gradient;
  final String subtitle;
  const _VideoMeta(this.title, this.url, this.icon, this.gradient, this.subtitle);
}

class _FeaturedVideoCard extends StatelessWidget {
  final _VideoMeta meta;
  const _FeaturedVideoCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVideoPopup(context, meta.title, meta.url),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.baseBr,
          border: Border.all(color: context.borderColor),
          boxShadow: context.cardShadow,
          color: context.cardColor,
        ),
        child: Column(
          children: [
            // Gradient thumbnail with play button
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: meta.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle pattern
                  Positioned(
                    right: 20,
                    bottom: 10,
                    child: Icon(
                      meta.icon,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  // Play button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
            // Title bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: meta.gradient.first.withValues(alpha: 0.1),
                    ),
                    child: Icon(meta.icon, color: meta.gradient.first, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.title,
                          style: AppTypography.titleMedium
                              .copyWith(color: context.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta.subtitle,
                          style: AppTypography.bodySmall
                              .copyWith(color: context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: context.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── What RD Fresh Does — 2x2 Grid with Material Icons ───
class _WhatItDoesSection extends StatelessWidget {
  static const _cards = [
    _FeatureCardData(
      Icons.water_drop_rounded,
      Color(0xFF2563EB),
      AppStrings.aboutMoisture,
      AppStrings.aboutMoistureDesc,
    ),
    _FeatureCardData(
      Icons.air_rounded,
      Color(0xFF059669),
      AppStrings.aboutAirflow,
      AppStrings.aboutAirflowDesc,
    ),
    _FeatureCardData(
      Icons.spa_rounded,
      Color(0xFF7C3AED),
      AppStrings.aboutOdors,
      AppStrings.aboutOdorsDesc,
    ),
    _FeatureCardData(
      Icons.thermostat_rounded,
      Color(0xFFD97706),
      AppStrings.aboutTemp,
      AppStrings.aboutTempDesc,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What RD Fresh Does',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: _cards.map((c) => _FeatureCard(data: c)).toList(),
        ),
      ],
    );
  }
}

class _FeatureCardData {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _FeatureCardData(this.icon, this.color, this.title, this.desc);
}

class _FeatureCard extends StatelessWidget {
  final _FeatureCardData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdBr,
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(height: 14),
          AutoSizeText(
            data.title,
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            minFontSize: 11,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              data.desc,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── The Numbers — Horizontal Scrollable ───
class _TheNumbersSection extends StatelessWidget {
  static const _stats = [
    _StatData(AppStrings.statShelfLife, AppStrings.statShelfLifeLabel),
    _StatData(AppStrings.statWaste, AppStrings.statWasteLabel),
    _StatData(AppStrings.statTemp, AppStrings.statTempLabel),
    _StatData(AppStrings.statROI, AppStrings.statROILabel),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'The Numbers',
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final s = _stats[i];
              return Container(
                width: 165,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: AppRadius.baseBr,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      s.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      minFontSize: 18,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatData {
  final String value;
  final String label;
  const _StatData(this.value, this.label);
}

// ─── The Problem — Visual Chain ───
class _TheProblemSection extends StatelessWidget {
  static const _steps = [
    (AppStrings.problemStep1, Icons.water_drop_outlined),
    (AppStrings.problemStep2, Icons.ac_unit_rounded),
    (AppStrings.problemStep3, Icons.air_rounded),
    (AppStrings.problemStep4, Icons.thermostat_rounded),
    (AppStrings.problemStep5, Icons.warning_amber_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Problem',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: AppRadius.baseBr,
            border: Border.all(color: context.borderColor),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isEven) {
                final stepIdx = i ~/ 2;
                final isLast = stepIdx == _steps.length - 1;
                return Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLast
                            ? AppColors.error.withValues(alpha: 0.12)
                            : AppColors.primaryGreen.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        _steps[stepIdx].$2,
                        size: 18,
                        color: isLast ? AppColors.error : AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _steps[stepIdx].$1,
                        style: AppTypography.titleMedium.copyWith(
                          color: isLast ? AppColors.error : context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Column(
                  children: [
                    Container(
                      width: 2,
                      height: 14,
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Before vs After ───
class _BeforeAfterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Before vs After',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: AppRadius.baseBr,
            border: Border.all(color: context.borderColor),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'WITHOUT RD FRESH',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.error,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 20, color: context.borderColor),
                    Expanded(
                      child: Center(
                        child: Text(
                          'WITH RD FRESH',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...List.generate(AppStrings.beforeItems.length, (i) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.close_rounded,
                              size: 14, color: AppColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              AppStrings.beforeItems[i],
                              style: AppTypography.bodySmall
                                  .copyWith(color: context.textSecondary),
                            ),
                          ),
                          Container(
                              width: 1, height: 28, color: context.borderColor),
                          const SizedBox(width: 6),
                          Icon(Icons.check_rounded,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              AppStrings.afterItems[i],
                              style: AppTypography.bodySmall
                                  .copyWith(color: context.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < AppStrings.beforeItems.length - 1)
                      Divider(height: 1, color: context.borderColor),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Value Chain — Horizontal Flow ───
class _ValueChainSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Value Chain',
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AppStrings.valueChain.length * 2 - 1,
            itemBuilder: (context, i) {
              if (i.isEven) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: AppRadius.pillBr,
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.valueChain[i ~/ 2],
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── ESG & Sustainability ───
class _ESGSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.public_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.esgTitle,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.esgBody,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.success.withValues(alpha: 0.85),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Video Popup (shared utility) ───
void _showVideoPopup(BuildContext context, String title, String url) {
  final videoId = YoutubePlayer.convertUrlToId(url);
  if (videoId == null) return;

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (ctx) => _VideoPopupDialog(title: title, videoId: videoId),
  );
}

class _VideoPopupDialog extends StatefulWidget {
  final String title;
  final String videoId;
  const _VideoPopupDialog({required this.title, required this.videoId});

  @override
  State<_VideoPopupDialog> createState() => _VideoPopupDialogState();
}

class _VideoPopupDialogState extends State<_VideoPopupDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title bar
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B3A2D),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // Player
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    aspectRatio: 16 / 9,
                    progressIndicatorColor: AppColors.primaryGreen,
                    progressColors: const ProgressBarColors(
                      playedColor: AppColors.primaryGreen,
                      handleColor: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

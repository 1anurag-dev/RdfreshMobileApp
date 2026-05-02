import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class VideoLibraryCard extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoLibraryCard({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<VideoLibraryCard> createState() => _VideoLibraryCardState();
}

class _VideoLibraryCardState extends State<VideoLibraryCard> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        forceHD: false,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lgBr,
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              aspectRatio: 16 / 9,
              progressIndicatorColor: AppColors.primaryGreen,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primaryGreen,
                handleColor: AppColors.primaryGreen,
              ),
              bottomActions: [
                CurrentPosition(),
                ProgressBar(isExpanded: true),
                RemainingDuration(),
                const PlaybackSpeedButton(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Text(
              widget.title,
              style: AppTypography.titleMedium.copyWith(
                color: context.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A reusable component that displays an embedded YouTube video

class SectionPageYouTubeVideo extends StatefulWidget {
  final String url;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  const SectionPageYouTubeVideo({
    super.key,
    required this.url,
    this.borderRadius = 12.0,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  State<SectionPageYouTubeVideo> createState() => _SectionPageYouTubeVideoState();
}

class _SectionPageYouTubeVideoState extends State<SectionPageYouTubeVideo> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
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
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.redAccent,
        bottomActions: [
          const SizedBox(width: 14.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          ProgressBar(isExpanded: true),
          const SizedBox(width: 8.0),
          RemainingDuration(),
          const PlaybackSpeedButton(),
        ],
      ),
    );
  }
}

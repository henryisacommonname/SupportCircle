import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String? youtubeURL;
  const YouTubePlayerWidget({super.key, required this.youtubeURL});

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final videoId = _extractVideoId(widget.youtubeURL);
    if (videoId == null) {
      setState(() => _isLoading = false);
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );

    setState(() => _isLoading = false);
  }

  static String? _extractVideoId(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();

    // Handle youtu.be short URLs
    final shortMatch =
        RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (shortMatch != null) return shortMatch.group(1);

    // Handle standard youtube.com URLs
    final standardMatch =
        RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (standardMatch != null) return standardMatch.group(1);

    // Handle youtube.com/embed URLs
    final embedMatch =
        RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (embedMatch != null) return embedMatch.group(1);

    // Handle youtube.com/v URLs
    final vMatch =
        RegExp(r'youtube\.com/v/([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (vMatch != null) return vMatch.group(1);

    return null;
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty if no valid URL
    if (widget.youtubeURL == null || widget.youtubeURL!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final videoId = _extractVideoId(widget.youtubeURL);
    if (videoId == null) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(controller: _controller!),
    );
  }
}

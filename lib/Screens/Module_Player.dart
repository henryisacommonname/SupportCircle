import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Core/Training_Repository.dart';
import 'package:video_player/video_player.dart';

class ModulePlayerScreen extends StatefulWidget {
  final TrainingModule Trainingscreen;
  const ModulePlayerScreen({super.key, required this.Trainingscreen});
  @override
  State<ModulePlayerScreen> createState() => ModulePlayerScreenState();
}

class ModulePlayerScreenState extends State<ModulePlayerScreen> {
  late final TrainingRepository Repo;
  bool loadingVideo = false;
  VideoPlayerController VC;

  // VideoPlayerController? _controller;
  @override
  Widget build(BuildContext context) {
    final m = widget.Trainingscreen;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(m.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (m.contentType == "video" && m.contentURL != null)
            {VideoSection(VideoController: VC, IsLoading: loadingVideo)}, //FIXME
        ],
      ),
    );
  }
}

class VideoSection extends StatelessWidget {
  final VideoPlayerController? VideoController;
  final bool IsLoading;
  const VideoSection({required this.VideoController, required this.IsLoading});

  @override
  Widget build(BuildContext context) {
    if (IsLoading) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (VideoController == null || !VideoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: Icon(Icons.play_disabled)),
      );
    }
    ;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: VideoController!.value.aspectRatio == 0
            ? (16 / 9)
            : VideoController!.value.aspectRatio,
        child: VideoPlayer(VideoController!),
      ),
    );
  }
}

class ArticleText extends StatelessWidget {
  final String? Subtitle;
  final String? BodyText;

  const ArticleText({required this.Subtitle, required this.BodyText});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Subtitle!, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Text(BodyText!.trim()),
      ],
    );
  }
}

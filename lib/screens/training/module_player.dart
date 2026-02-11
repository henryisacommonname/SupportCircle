import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/training_module.dart';
import '../../services/training_repository.dart';
import '../../widgets/youtube_player.dart';

class ModulePlayerScreen extends StatefulWidget {
  final TrainingModule module;
  final bool canTrackProgress;

  const ModulePlayerScreen({
    super.key,
    required this.module,
    required this.canTrackProgress,
  });

  @override
  State<ModulePlayerScreen> createState() => _ModulePlayerScreenState();
}

class _ModulePlayerScreenState extends State<ModulePlayerScreen> {
  late final TrainingRepository _repo;
  VideoPlayerController? _videoController;
  bool _isLoadingVideo = false;
  bool _isMarking = false;

  @override
  void initState() {
    super.initState();
    _repo = TrainingRepository();

    if (widget.module.contentType == 'video' &&
        widget.module.contentURL != null &&
        widget.module.contentURL!.isNotEmpty) {
      _initVideo(widget.module.contentURL!);
    }
  }

  Future<void> _initVideo(String url) async {
    setState(() => _isLoadingVideo = true);
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;
    await controller.initialize();
    await controller.setLooping(false);
    setState(() => _isLoadingVideo = false);
  }

  Future<void> _markComplete() async {
    if (!widget.canTrackProgress) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isMarking = true);
    try {
      await _repo.setStatus(
        uid: uid,
        moduleId: widget.module.id,
        status: ModuleStatus.completed,
      );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isMarking = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool get _hasYoutubeURL =>
      widget.module.youtubeURL != null &&
      widget.module.youtubeURL!.trim().isNotEmpty;

  bool get _hasVideoURL =>
      widget.module.contentType == 'video' &&
      widget.module.contentURL != null &&
      widget.module.contentURL!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_hasYoutubeURL)
            YouTubePlayerWidget(youtubeURL: module.youtubeURL)
          else if (_hasVideoURL)
            _VideoSection(
              controller: _videoController,
              loading: _isLoadingVideo,
            )
          else
            _ArticleSection(subtitle: module.subtitle, body: module.body),

          if ((_hasYoutubeURL || _hasVideoURL) &&
              ((module.body ?? '').trim().isNotEmpty ||
                  module.subtitle.trim().isNotEmpty)) ...[
            const SizedBox(height: 16),
            _ArticleSection(subtitle: module.subtitle, body: module.body),
          ],

          const SizedBox(height: 16),
          if (widget.canTrackProgress)
            FilledButton.icon(
              onPressed: _isMarking ? null : _markComplete,
              icon: _isMarking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isMarking ? 'Marking...' : 'Mark Complete'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In to Track Completion'),
            ),
          const SizedBox(height: 8),
          Text(
            'Takes ~${module.minutes} min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      floatingActionButton:
          (!_hasYoutubeURL && _hasVideoURL && _videoController != null)
          ? FloatingActionButton(
              onPressed: () {
                final v = _videoController!;
                if (v.value.isPlaying) {
                  v.pause();
                } else {
                  v.play();
                }
                setState(() {});
              },
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}

class _VideoSection extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool loading;
  const _VideoSection({required this.controller, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller == null || !controller!.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: Icon(Icons.play_disabled)),
      );
    }
    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio == 0
          ? (16 / 9)
          : controller!.value.aspectRatio,
      child: VideoPlayer(controller!),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  final String? subtitle;
  final String? body;
  const _ArticleSection({required this.subtitle, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeSubtitle = (subtitle ?? '').trim();
    final safeBody = (body ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (safeSubtitle.isNotEmpty)
          Text(safeSubtitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Text(
          safeBody.isNotEmpty
              ? safeBody
              : 'Read the guidance above, then tap "Mark Complete" when finished.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

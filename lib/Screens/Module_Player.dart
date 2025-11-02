//Module_Player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Core/Training_Repository.dart';

class ModulePlayerScreen extends StatefulWidget {
  final TrainingModule module;
  const ModulePlayerScreen({super.key, required this.module});

  @override
  State<ModulePlayerScreen> createState() => ModulePlayerScreenState();
}

class ModulePlayerScreenState extends State<ModulePlayerScreen> {
  late final TrainingRepository repo;

  VideoPlayerController? videoController;
  bool isLoadingVideo = false;
  bool isMarking = false;

  @override
  void initState() {
    super.initState();
    repo = TrainingRepository();

    if (widget.module.contentType == 'video' &&
        widget.module.contentURL != null &&
        widget.module.contentURL!.isNotEmpty) {
      _initVideo(widget.module.contentURL!);
    }
  }

  Future<void> _initVideo(String url) async {
    setState(() => isLoadingVideo = true);
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    videoController = c;
    await c.initialize();
    await c.setLooping(false);
    setState(() => isLoadingVideo = false);
  }

  Future<void> _markComplete() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => isMarking = true);
    try {
      await repo.setStatus(
        uid: uid,
        moduleId: widget.module.id, // ensure repo expects moduleId (camelCase)
        status: ModuleStatus.completed,
      );
      if (mounted) Navigator.pop(context, true); // return to list
    } finally {
      if (mounted) setState(() => isMarking = false);
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(m.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (m.contentType == 'video' && m.contentURL != null)
            _VideoSection(controller: videoController, loading: isLoadingVideo)
          else
            _ArticleSection(subtitle: m.subtitle, body: m.body),

          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isMarking ? null : _markComplete,
            icon: isMarking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(isMarking ? 'Marking…' : 'Mark Complete'),
          ),
          const SizedBox(height: 8),
          Text(
            'Takes ~${m.minutes} min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      floatingActionButton:
          (m.contentType == 'video' && videoController != null)
          ? FloatingActionButton(
              onPressed: () {
                final v = videoController!;
                if (v.value.isPlaying) {
                  v.pause();
                } else {
                  v.play();
                }
                setState(() {});
              },
              child: Icon(
                videoController!.value.isPlaying
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
    // No rounded corners per your preference
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
              : 'Read the guidance above, then tap “Mark Complete” when finished.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

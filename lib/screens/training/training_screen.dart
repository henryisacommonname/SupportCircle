import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/training_module.dart';
import '../../services/training_repository.dart';
import 'module_player.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _repo = TrainingRepository();

  ({int completed, int total, double ratio}) _progressOf(
    List<TrainingModule> modules,
  ) {
    final total = modules.length;
    if (total == 0) return (completed: 0, total: 0, ratio: 0);

    final completed = modules
        .where((m) => m.status == ModuleStatus.completed)
        .length;
    final ratio = completed / total;
    return (completed: completed, total: total, ratio: ratio);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isSignedIn = uid != null;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: StreamBuilder(
        stream: isSignedIn ? _repo.modulesWithStatus(uid) : _repo.modules(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Unable to load training modules right now.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }

          final modules = snap.data ?? const <TrainingModule>[];
          final progress = _progressOf(modules);
          final pctText = isSignedIn
              ? '${progress.completed} of ${progress.total} modules completed'
              : '${progress.total} modules available';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!isSignedIn) ...[
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You are viewing training as a guest',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to save progress and mark modules as completed.',
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/login'),
                          icon: const Icon(Icons.login),
                          label: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.deepPurple.withAlpha(13),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(isSignedIn ? 'Your Progress' : 'Training Library'),
                    const SizedBox(height: 10),
                    ClipRRect(
                      child: LinearProgressIndicator(
                        value: isSignedIn ? progress.ratio : 1,
                        minHeight: 10,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          scheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(pctText),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (modules.isEmpty)
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Training modules are currently unavailable. Please check back soon.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              for (final module in modules)
                TrainingModuleCard(
                  module: module,
                  onTap: () async {
                    if (uid != null) {
                      await _repo.setStatus(
                        uid: uid,
                        moduleId: module.id,
                        status: ModuleStatus.inProgress,
                      );
                    }
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModulePlayerScreen(
                          module: module,
                          canTrackProgress: isSignedIn,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ModuleImagePlaceholder extends StatefulWidget {
  const _ModuleImagePlaceholder();

  @override
  State<_ModuleImagePlaceholder> createState() =>
      _ModuleImagePlaceholderState();
}

class _ModuleImagePlaceholderState extends State<_ModuleImagePlaceholder> {
  late Color _backgroundColor;

  @override
  void initState() {
    super.initState();
    _backgroundColor = _randomThemeColor();
  }

  Color _randomThemeColor() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.tertiaryColor,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.info,
      AppTheme.primaryColor.withAlpha(200),
      AppTheme.secondaryColor.withAlpha(200),
      const Color(0xFF536DFE), // Indigo variant
      const Color(0xFF6A5ACD), // Slate blue
      const Color(0xFF4169E1), // Royal blue (slightly different shade)
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/SupportCircleCropped.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;
  final VoidCallback? onTap;

  const TrainingModuleCard({
    super.key,
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeText;

    switch (module.status) {
      case ModuleStatus.completed:
        badgeText = 'Completed';
        badgeColor = const Color(0xFF2BB673);
        break;
      case ModuleStatus.inProgress:
        badgeText = 'In Progress';
        badgeColor = const Color(0xFFF6A21A);
        break;
      default:
        badgeText = 'Not Started';
        badgeColor = const Color(0xFF607D8B);
    }

    final hasHeaderImage = module.hasImage;
    final headerImage = hasHeaderImage
        ? Image.network(
            module.imageURL!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _ModuleImagePlaceholder(),
          )
        : const _ModuleImagePlaceholder();

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  child: AspectRatio(aspectRatio: 16 / 9, child: headerImage),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(badgeText),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(module.title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(module.subtitle),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 8, bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.access_alarms_outlined),
                  const SizedBox(width: 5),
                  Text('${module.minutes} Min'),
                  const Spacer(),
                  if (module.status == ModuleStatus.completed)
                    TextButton(onPressed: onTap, child: const Text('Review'))
                  else if (module.status == ModuleStatus.inProgress)
                    TextButton(onPressed: onTap, child: const Text('Resume'))
                  else
                    TextButton(onPressed: onTap, child: const Text('Start')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

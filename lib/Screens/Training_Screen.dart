import 'package:draft_1/Screens/Module_Player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Core/Training_Repository.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen> {
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
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in,')));
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Training")),
      body: StreamBuilder(
        stream: _repo.ModuleswithStatus(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("ERROR -${snap.error}"));
          }
          final modules = snap.data ?? const <TrainingModule>[];
          final progress = _progressOf(modules);
          final pctText =
              '${progress.completed} of ${progress.total} modules completed';
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.deepPurple.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text('Your Progress'),
                    const SizedBox(height: 10),
                    ClipRRect(
                      child: LinearProgressIndicator(
                        value: progress.ratio,
                        minHeight: 10,
                        backgroundColor: scheme.surfaceVariant,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(scheme.primary),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(pctText),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final M in modules)
                TrainingModuleCard(
                  module: M,
                  onTap: () async {
                    await _repo.setStatus(
                      uid: uid,
                      moduleid: M.id,
                      status: ModuleStatus.inProgress,
                    );
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModulePlayerScreen(module: M),
                      ),
                    );
                  },
                  onReview: M.status == ModuleStatus.completed
                      ? () {
                          //TODO DO SOMETHING HERE, like an animation
                        }
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ModuleImagePlaceholder extends StatelessWidget {
  const _ModuleImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 42,
          color: scheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
    );
  }
}

class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const TrainingModuleCard({
    super.key,
    required this.module,
    required this.onTap,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color BadgeColor;
    String badgeText;

    switch (module.status) {
      case ModuleStatus.completed:
        badgeText = "completed!";
        BadgeColor = const Color(0xFF2BB673);
        break;
      case ModuleStatus.inProgress:
        badgeText = "inProgress";
        BadgeColor = const Color(0xFFF6A21A);
        break;
      default:
        badgeText = "Not Started";
        BadgeColor = const Color(0xFFE53935);
    }
    final hasHeaderImage = module.hasimage;
    Widget StatusBadge() => Container(child: Text(badgeText));
    final headerImage = hasHeaderImage
        ? Image.network(
            module.imageURL!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ModuleImagePlaceholder(),
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
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: headerImage,
                  ),
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
                      color: BadgeColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(badgeText),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(module.title),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(module.subtitle),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(
                left: 14,
                right: 8,
                bottom: 12,
                top: 0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_alarms_outlined),
                  const SizedBox(width: 5),
                  Text("${module.minutes} Min"),
                  Spacer(),
                  if (onReview != null)
                    TextButton(onPressed: onReview, child: const Text("Review"))
                  else if (module.status == ModuleStatus.inProgress)
                    TextButton(onPressed: onTap, child: Text("Resume"))
                  else
                    TextButton(onPressed: onTap, child: Text("Start")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  double _completionOf(List<TrainingModule> Modules) {
    if (Modules.isEmpty) {
      return 0;
    }
    final Done = Modules.where(
      (M) => M.status == ModuleStatus.completed,
    ).length;
    return Done / Modules.length;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in,')));
    }
    final theme = Theme.of(context);
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
          final completion = _completionOf(modules);
          final pctText =
              '${(completion * 100).round()}% of modules completed';
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
                        value: completion,
                        minHeight: 10,
                        backgroundColor: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Replace Me!!'),
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

class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const TrainingModuleCard({super.key, 
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
                    child: Image.network(module.imageURL, fit: BoxFit.cover),
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

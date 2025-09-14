import 'package:flutter/material.dart';

enum ModuleStatus { notStarted, inProgress, completed }

class TrainingModule {
  final String id;
  final String title;
  final String subtitle;
  final String imageURL;
  final int minutes;
  final ModuleStatus status;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageURL,
    required this.minutes,
    required this.status,
  });
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen> {
  final List<TrainingModule> _modules = const [
    TrainingModule(
      id: 'mod_1',
      title: 'Understanding Child Behavior',
      subtitle: 'Learn to recognize and respond to different emotional states',
      minutes: 15,
      imageURL:
          'https://images.unsplash.com/photo-1613836258403-6b9aa7ee3174?q=80&w=1200&auto=format&fit=crop',
      status: ModuleStatus.completed,
    ),
    TrainingModule(
      id: 'mod_2',
      title: 'Safe Play Activities',
      subtitle: 'Engaging activities that promote emotional safety and growth',
      minutes: 12,
      imageURL:
          'https://images.unsplash.com/photo-1542280756-74b2f55e73e1?q=80&w=1200&auto=format&fit=crop',
      status: ModuleStatus.inProgress,
    ),
  ];

  double get _completion {
    if (_modules.isEmpty) return 0;
    final done = _modules
        .where((m) => m.status == ModuleStatus.completed)
        .length;
    return done / _modules.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Training")),
      body: ListView(
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
                    value: _completion,
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
          for(final m in _modules)
            TrainingModuleCard(module: m, onTap: (){}, onReview: m.status == ModuleStatus.completed?(){}: null)
        ],
      ),
    );
  }
}

class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const TrainingModuleCard({
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

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
  final List<TrainingModule> _modules = const [];

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
      case ModuleStatus.completed: badgeText = "completed!";
      BadgeColor = const Color(0xFF2BB673);
      break;
      case ModuleStatus.inProgress: badgeText = "inProgress";
      BadgeColor = const Color(0xFFF6A21A);
      break;
      default: badgeText = "Not Started";
      BadgeColor = const Color(0xFFE53935);

    }
    return InkWell(child: Container(child: Column(),),);

  }
}

//Home_Tab.dart
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WelcomeCard(),
          const SizedBox(height: 12),
          QuickActionsRow(),
          const SizedBox(height: 12),
          const SectionHeader(Title: 'Resources'),
          const SizedBox(height: 8),
          ..._mockResources.map((r) => ResourceCard(Resource: r)),
        ],
      ),
    );
  }
}

/*--- Components ---*/
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to SupportCircle',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'supporting children and family together',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: QuickActionsCard(
            title: 'AI Assistant',
            subtitle: 'get real-time help',
            QAIcon: Icons.smart_toy_outlined,
            QAroute: '/assistant',
            color: Colors.white,
          ),
        ),

        SizedBox(width: 12),
        Expanded(
          child: QuickActionsCard(
            title: 'Emergency',
            subtitle: 'Quick help access',
            QAIcon: Icons.call,
            QAroute: '/emergency',
            emph: true,
          ),
        ),
      ],
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  final Color? color;
  final String title;
  final String subtitle;
  final IconData QAIcon;
  final String QAroute;
  final bool emph;
  const QuickActionsCard({super.key, 
    required this.title,
    required this.subtitle,
    required this.QAIcon,
    required this.QAroute,
    this.emph = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Scheme = Theme.of(context).colorScheme;
    final bg = color;
    final fg = emph ? Scheme.onErrorContainer : Scheme.onSurface;

    return Card(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(QAroute),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(QAIcon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w700, color: fg),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: fg.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String Title;
  const SectionHeader({super.key, required this.Title});

  @override
  Widget build(BuildContext context) {
    return Text(
      Title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class ResourceCard extends StatelessWidget {
  final resource Resource;
  const ResourceCard({super.key, required this.Resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(Resource.ResourceIcon),
        onTap: () => Navigator.of(
          context,
        ).pushNamed("/Resources", arguments: Resource.ID),
        title: Text(
          Resource.Title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(Resource.Subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class resource {
  final String ID;
  final String Title;
  final String Subtitle;
  final IconData ResourceIcon;
  const resource({
    required this.ID,
    required this.Title,
    required this.Subtitle,
    required this.ResourceIcon,
  });
}

const _mockResources = <resource>[
  resource(
    ID: 'child-dev-guide',
    Title: 'Child Development Guide',
    Subtitle: 'Understanding child behavior',
    ResourceIcon: Icons.menu_book_outlined,
  ),
  resource(
    ID: 'parenting-classes',
    Title: 'Parenting Classes',
    Subtitle: 'Learn effective techniques',
    ResourceIcon: Icons.school_outlined,
  ),
];

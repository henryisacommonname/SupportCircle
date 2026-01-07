//Home_Tab.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Core/Services/Resources_Repository.dart';
import 'Resources_Screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static final ResourcesRepository resources_repository = ResourcesRepository();
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
          StreamBuilder<List<AppResource>>(
            stream: resources_repository.Featuredresources(max: 3),
            builder: (context, snapshot) {
              if (kDebugMode) {
                debugPrint(
                  '[HomeTab] resources state=${snapshot.connectionState} '
                  'hasError=${snapshot.hasError} '
                  'count=${snapshot.data?.length ?? 0}',
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ResourcePlaceholder();
              }
              if (snapshot.hasError) {
                return Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Unable to load resources.\n${snapshot.error}'),
                  ),
                );
              }
              final resources = snapshot.data ?? const [];
              if (resources.isEmpty) {
                return const Card(
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No resources available yet.'),
                  ),
                );
              }
              return Column(
                children: resources
                    .map((r) => ResourceCard(Resource: r))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          const SectionHeader(Title: 'Shortcuts'),
          const SizedBox(height: 8),
          ShortcutCard(
            icon: Icons.school_outlined,
            title: 'Resume Training',
            subtitle: 'Jump back into the latest module',
            onTap: () => Navigator.of(context).pushNamed('/training'),
          ),
          const SizedBox(height: 8),
          ShortcutCard(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your info instantly',
            onTap: () => Navigator.of(context).pushNamed('/profile/edit'),
          ),
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
  const QuickActionsCard({
    super.key,
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

class ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const ShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest.withOpacity(0.35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 28, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ResourcePlaceholder extends StatelessWidget {
  const ResourcePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: ListTile(
        leading: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        title: Text("Loading Resources"),
      ),
    );
  }
}

class ResourceCard extends StatelessWidget {
  final AppResource Resource;
  const ResourceCard({super.key, required this.Resource});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        leading: Icon(Resource.icon),
        onTap: () => Navigator.of(
          context,
        ).pushNamed(ResourcesScreen.routeName, arguments: Resource.id),
        title: Text(
          Resource.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(Resource.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

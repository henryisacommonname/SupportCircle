import 'package:flutter/material.dart';

import '../../models/app_resource.dart';
import '../../services/resource_repository.dart';
import 'resource_player.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  static const String routeName = '/resources';

  @override
  Widget build(BuildContext context) {
    final repo = ResourceRepository();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.blueGrey,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resources',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Check out our documents to find helpful information for your outing!',
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder(
                          stream: repo.allResources(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const _ResourceSkeletonList();
                            }
                            if (snapshot.hasError) {
                              return const Text('Unable to Access our Resources');
                            }

                            final resources = snapshot.data ?? [];
                            return Column(
                              children: [
                                for (final res in resources) ...[
                                  _ResourceCard(
                                    resource: res,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ResourcePlayerScreen(resource: res),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatefulWidget {
  final AppResource resource;
  final VoidCallback onTap;
  const _ResourceCard({required this.resource, required this.onTap});

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final baseColor = scheme.surface;
    final hoverColor = scheme.primary.withAlpha(13);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: _hovering ? hoverColor : baseColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: scheme.outlineVariant.withAlpha(128)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResourceIcon(icon: widget.resource.icon, color: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.resource.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResourceIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _ResourceIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _ResourceSkeletonList extends StatelessWidget {
  const _ResourceSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i == 2 ? 0 : 12),
          child: const _ResourceSkeletonCard(),
        ),
      ),
    );
  }
}

class _ResourceSkeletonCard extends StatelessWidget {
  const _ResourceSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withAlpha(128)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBar(context, width: 180),
                const SizedBox(height: 8),
                _skeletonBar(context, width: 240),
                const SizedBox(height: 4),
                _skeletonBar(context, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBar(BuildContext context, {required double width}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

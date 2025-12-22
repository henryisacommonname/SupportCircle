import 'package:draft_1/Core/Services/resource_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  static const String routeName = '/Resources';

  @override
  Widget build(BuildContext context) {
    final repository = ResourceRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: StreamBuilder<List<AppResource>>(
        stream: repository.allResources(),
        builder: (context, snapshot) {
          if (kDebugMode) {
            debugPrint(
              '[ResourcesScreen] state=${snapshot.connectionState} '
              'hasError=${snapshot.hasError} '
              'count=${snapshot.data?.length ?? 0}',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading resources: ${snapshot.error}'),
            );
          }
          final resources = snapshot.data ?? const [];
          if (resources.isEmpty) {
            return const Center(child: Text('No resources found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: resources.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(resource.icon),
                  title: Text(
                    resource.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(resource.subtitle),
                  onTap: () {
                    if (kDebugMode) {
                      debugPrint('[ResourcesScreen] tapped ${resource.id}');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/app_resource.dart';
import '../../widgets/youtube_player.dart';

class ResourcePlayerScreen extends StatelessWidget {
  final AppResource resource;
  const ResourcePlayerScreen({super.key, required this.resource});

  static const String routeName = '/resource-player';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasYoutubeURL =
        resource.youtubeURL != null && resource.youtubeURL!.trim().isNotEmpty;
    final hasBody = (resource.body ?? '').trim().isNotEmpty;
    final hasSubtitle = resource.subtitle.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(resource.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasYoutubeURL) ...[
            YouTubePlayerWidget(youtubeURL: resource.youtubeURL),
            const SizedBox(height: 16),
          ],

          if (hasSubtitle)
            Text(resource.subtitle, style: theme.textTheme.titleMedium),

          if (hasSubtitle && hasBody) const SizedBox(height: 10),

          if (hasBody)
            Text(resource.body!, style: theme.textTheme.bodyMedium),

          if (!hasYoutubeURL && !hasBody && !hasSubtitle)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No additional content available for this resource.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

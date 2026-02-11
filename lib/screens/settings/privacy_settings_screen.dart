import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How your data is used', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'SupportCircle stores your account profile, volunteer hour logs, and training progress in Firebase so your experience is synced across devices. '
                    'Location access is only used to show nearby opportunities in the Support tab.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Account'),
              subtitle: const Text(
                'Available from Profile > Danger Zone when signed in.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

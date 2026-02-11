import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  static bool _remindersEnabled = true;
  static bool _trainingUpdatesEnabled = true;
  static bool _communityAlertsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Volunteer Reminders'),
                  subtitle: const Text(
                    'Get reminders to log service hours after volunteering.',
                  ),
                  value: _remindersEnabled,
                  onChanged: (value) {
                    setState(() => _remindersEnabled = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Training Updates'),
                  subtitle: const Text(
                    'Receive updates when new training modules are published.',
                  ),
                  value: _trainingUpdatesEnabled,
                  onChanged: (value) {
                    setState(() => _trainingUpdatesEnabled = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Community Alerts'),
                  subtitle: const Text(
                    'Get nearby opportunity alerts when available.',
                  ),
                  value: _communityAlertsEnabled,
                  onChanged: (value) {
                    setState(() => _communityAlertsEnabled = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'These settings apply to this device.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

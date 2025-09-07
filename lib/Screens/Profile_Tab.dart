import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Core/Services/auth_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData ||
              snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() ?? <String, dynamic>{};

          // Read as nullable, then default
          final displayName = (data['DisplayName'] as String?)?.trim();
          final pfpURL = (data['pfpURL'] as String?)?.trim();
          final timeTracker = (data['TimeTracker'] ?? 0); // int or double

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeader(
                displayName: displayName?.isNotEmpty == true
                    ? displayName!
                    : 'Volunteer',
                pfpURL: (pfpURL?.isNotEmpty == true) ? pfpURL : null,
                hours: (timeTracker is num) ? timeTracker.toDouble() : 0.0,
              ),
              const SizedBox(height: 16),
              const Settings(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => AuthService().signOut(),
                label: const Text('Sign Out'),
                icon: const Icon(Icons.logout),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String displayName; // non-nullable (we pass a safe default)
  final String? pfpURL; // nullable
  final double hours; // show hours tracked

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.pfpURL,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = pfpURL != null && pfpURL!.isNotEmpty;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: hasImage ? NetworkImage(pfpURL!) : null,
              // show icon only when NO image
              child: hasImage ? null : const Icon(Icons.person, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Hours volunteered: ${hours.toStringAsFixed(1)}'),
                ],
              ),
            ),
        IconButton(
          onPressed: () =>
              Navigator.of(context).pushNamed("/profile/edit"),
          icon: Icon(Icons.edit),
          tooltip: "Edit Your profile!",
          ),
        ]),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage Your Alerts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context).pushNamed('/Settings/Notifications'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Privacy'),
            subtitle: const Text('Control Your Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/Settings/Privacy'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage Your Alerts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context).pushNamed('/Settings/Notifications'),
          ),
        ],
      ),
    );
  }
}

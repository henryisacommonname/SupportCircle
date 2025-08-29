import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Core/Services/auth_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final User = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(User.uid);
    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snap) {
          final UserData = snap.data?.data() ?? const {};
          final DisplayName = UserData['DisplayName'];
          final pfpURL = UserData['pfpURL'];
          final TimeTracker = UserData['TimeTracker'];
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              ProfileHeader(DisplayName: DisplayName, pfpURL: pfpURL),
              const SizedBox(height: 16),
              Settings(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => AuthService().signOut(),
                label: const Text('Sign Out'),
                icon: Icon(Icons.logout),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String DisplayName;
  final String? pfpURL;

  const ProfileHeader({required this.DisplayName, required this.pfpURL});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: (pfpURL != null && pfpURL!.isNotEmpty)
                  ? NetworkImage(pfpURL!)
                  : null,
              child: (pfpURL != null && pfpURL!.isNotEmpty)
                  ? const Icon(Icons.person, size: 28)
                  : null,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            leading: (const Icon(Icons.notifications)),
            title: Text('Notifications'),
            subtitle: Text('Manage Your Alerts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context).pushNamed('/Settings/Notifications'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: (const Icon(Icons.shield)),
            title: Text('Privacy'),
            subtitle: Text('Control Your Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/Settings/Privacy'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: (const Icon(Icons.help)),
            title: Text('Help & Support'),
            subtitle: Text('Get Assistance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/Settings/Support'),
          ),
        ],
      ),
    );
  }
}

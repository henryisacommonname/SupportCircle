import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app.dart';
import '../../config/app_themes.dart';
import '../../services/auth_service.dart';
import '../../widgets/onboarding_carousel.dart';

/// Global notifier to track if theme selector sheet is open
/// Used to hide AI FAB when the sheet is displayed
final ValueNotifier<bool> isThemeSelectorOpen = ValueNotifier(false);

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _GuestProfileView();
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
          final displayName = (data['DisplayName'] as String?)?.trim();
          final pfpURL = (data['pfpURL'] as String?)?.trim();
          final timeTracker = (data['TimeTracker'] ?? 0);

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
              const SizedBox(height: 24),
              const DeleteAccountCard(),
            ],
          );
        },
      ),
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use SupportCircle without an account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can browse resources, explore training content, and find volunteer opportunities now. '
                    'Sign in to save hours, track module progress, and personalize your profile.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/register'),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Settings(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String? pfpURL;
  final double hours;

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
              child: hasImage ? null : const Icon(Icons.person, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Hours volunteered: ${hours.toStringAsFixed(1)}'),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/profile/edit'),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Your profile!',
            ),
          ],
        ),
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
          ListenableBuilder(
            listenable: themeService,
            builder: (context, _) {
              final currentTheme = themeService.currentTheme;
              return ListTile(
                leading: Icon(currentTheme.icon),
                title: const Text('App Theme'),
                subtitle: Text(currentTheme.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeSelector(context),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage Your Alerts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context).pushNamed('/settings/notifications'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Privacy'),
            subtitle: const Text('Control Your Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/settings/privacy'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('View Tutorial'),
            subtitle: const Text('Learn how to use the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => OnboardingCarousel.show(context),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    isThemeSelectorOpen.value = true;
    showModalBottomSheet(
      context: context,
      builder: (context) => const ThemeSelectorSheet(),
    ).then((_) {
      isThemeSelectorOpen.value = false;
    });
  }
}

class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final allThemes = themeService.allThemes;
        final currentThemeId = themeService.currentThemeId;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha(77),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allThemes.length,
                  itemBuilder: (context, index) {
                    final theme = allThemes[index];
                    final isSelected = theme.id == currentThemeId;
                    final isUnlocked = themeService.isThemeUnlocked(theme.id);
                    final hoursNeeded = themeService.hoursToUnlock(theme.id);

                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: colorScheme.primary, width: 3)
                              : null,
                        ),
                        child: Icon(theme.icon, color: Colors.white),
                      ),
                      title: Row(
                        children: [
                          Text(theme.name),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                          ],
                          if (!isUnlocked && hoursNeeded != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$hoursNeeded hrs',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(theme.description),
                      trailing: _buildColorPreview(theme),
                      onTap: isUnlocked
                          ? () {
                              themeService.setTheme(theme.id);
                              Navigator.pop(context);
                            }
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorPreview(AppThemeConfig theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _colorDot(theme.primary),
        const SizedBox(width: 4),
        _colorDot(theme.secondary),
        const SizedBox(width: 4),
        _colorDot(theme.tertiary),
      ],
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class DeleteAccountCard extends StatefulWidget {
  const DeleteAccountCard({super.key});

  @override
  State<DeleteAccountCard> createState() => _DeleteAccountCardState();
}

class _DeleteAccountCardState extends State<DeleteAccountCard> {
  bool _isDeleting = false;
  bool _isExpanded = false;

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. '
          'All your data including volunteer hours and progress will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final uid = user.uid;

      // Delete user's Firestore data
      final firestore = FirebaseFirestore.instance;

      // Delete ModuleProgress subcollection
      final progressDocs = await firestore
          .collection('users')
          .doc(uid)
          .collection('ModuleProgress')
          .get();
      for (final doc in progressDocs.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await firestore.collection('users').doc(uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      // User will be automatically signed out and redirected by AuthGate
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);

      String message = 'Failed to delete account';
      if (e.code == 'requires-recent-login') {
        message =
            'Please sign out and sign in again, then try deleting your account';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: _isExpanded
          ? colorScheme.errorContainer.withAlpha(77)
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: _isExpanded
                        ? colorScheme.error
                        : colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Danger Zone',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isExpanded
                            ? colorScheme.error
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _isExpanded
                          ? colorScheme.error
                          : colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permanently delete your account and all associated data.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting ? null : _deleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      icon: _isDeleting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.error,
                              ),
                            )
                          : const Icon(Icons.delete_forever),
                      label: Text(
                        _isDeleting ? 'Deleting...' : 'Delete Account',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameCtrl = TextEditingController();
  final _pfpUrlCtrl = TextEditingController();

  bool _saving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _pfpUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await AuthService().updateUserProfile(
        displayName: _displayNameCtrl.text.trim(),
        photoURL: _pfpUrlCtrl.text.trim().isEmpty ? null : _pfpUrlCtrl.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() ?? <String, dynamic>{};

          if (!_prefilled) {
            _displayNameCtrl.text =
                ((data['DisplayName'] as String?) ?? 'Volunteer').trim();
            _pfpUrlCtrl.text = (data['pfpURL'] as String?)?.trim() ?? '';
            _prefilled = true;
          }

          final currentPhotoURL = _pfpUrlCtrl.text.trim();
          final hasPhoto = currentPhotoURL.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile picture preview
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage:
                          hasPhoto ? NetworkImage(currentPhotoURL) : null,
                      onBackgroundImageError: hasPhoto
                          ? (_, __) {} // Silently handle invalid URLs
                          : null,
                      child: hasPhoto
                          ? null
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display name field
                  TextFormField(
                    controller: _displayNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a display name';
                      }
                      if (v.trim().length > 20) {
                        return 'Name must be 20 characters or less';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Profile photo URL field
                  TextFormField(
                    controller: _pfpUrlCtrl,
                    decoration: InputDecoration(
                      labelText: 'Profile Photo URL',
                      prefixIcon: const Icon(Icons.link),
                      helperText: 'Paste a link to your profile picture',
                      suffixIcon: _pfpUrlCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _pfpUrlCtrl.clear());
                              },
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final uri = Uri.tryParse(v.trim());
                      final isValid =
                          uri != null && uri.hasScheme && uri.hasAuthority;
                      return isValid ? null : 'Please enter a valid URL';
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

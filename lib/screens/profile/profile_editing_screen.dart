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
  final _pfpCtrl = TextEditingController();
  bool _saving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _pfpCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService().updateUserProfile(
        displayName: _displayNameCtrl.text.trim(),
        photoURL: _pfpCtrl.text.trim().isEmpty ? null : _pfpCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
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

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
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
            _pfpCtrl.text = (data['pfpURL'] as String?)?.trim() ?? '';
            _prefilled = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Invalid username';
                        if (v.trim().length > 20) return 'Username too long';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pfpCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Profile Photo URL',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final uri = Uri.tryParse(v.trim());
                        final ok = uri != null && uri.hasScheme && uri.hasAuthority;
                        return ok ? null : 'Enter a valid URL';
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                            : const Text('Save Your Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

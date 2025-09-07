import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Core/Services/auth_service.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});
  @override
  State<ProfileEditingScreen> createState() => ProfileEditingScreenState();
}

class ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameCtrl = TextEditingController();
  final _pfpCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _pfpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User = FirebaseAuth.instance.currentUser;
    if (User == null) {
      return const Scaffold(body: Center(child: Text('not signed in')));
    }
    final UserRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(User.uid);
    return Scaffold(
      appBar: AppBar(title: Text('Edit Your Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserRef.snapshots(),
        builder: (context, snap) {
          return ListView(
            children: [
              Center(),
              const SizedBox(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Display Name",
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Invalid Username";
                        }
                        if (v.trim().length > 20) {
                          return "Username too long";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(),
                    TextFormField(
                      controller: _pfpCtrl,
                      decoration: const InputDecoration(
                        labelText: "Profile Photo URL",
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}), //refresh preview
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return null;
                        }
                        final IsValid =
                            Uri.tryParse(v.trim())?.hasAbsolutePath ?? false;
                        return IsValid ? null : "Enter a Valid URL";
                      },
                    ),
                    const SizedBox(),
                    Card(),
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

//actions: [TextButton(onPressed: _saving ? null : () async {if (!_formKey.currentState!.validate()) return; setState(() => _saving = true);
//try {await AuthService().updateuserProfile(displayName: _displaynameCtrl.text.trim(),PhotoURL: _pfpCtrl.text.trim().isEmpty ? null : _pfpCtrl.text.trim(),);}; child: _saving;})],));

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
    return Scaffold(appBar: AppBar(title: Text('Edit Your Profile')));
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Core/Services/auth_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final User = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(User.uid);
    return SafeArea(child: StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      stream: userRef.snapshots(),
      builder: (context,snap){
        final UserData= snap.data?.data() ?? const {};





        // TODO: implement fallbacks



        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // TODO: implement Profile Header
          ],
        );

      },
    ));
  }
}
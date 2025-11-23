// auth_service.dart
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await ensureUserDoc(cred.user!);
    return cred.user;
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await ensureUserDoc(cred.user!); // ensure profile doc right after register
    return cred;
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> UpdateUserProfile({
    required String DisplayName,
    String? PhotoURL,
  }) async {
    final User = _auth.currentUser;
    if (User == null) throw Exception('User Not Sign In');
    await User.updateDisplayName(DisplayName);
    if (PhotoURL != null) {
      await User.updatePhotoURL(PhotoURL);
    }
    await User.reload();
    final doc = FirebaseFirestore.instance.collection('users').doc(User.uid);
    await doc.set({
      'DisplayName': DisplayName,
      'pfpURL': PhotoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserDoc(User user) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'DisplayName': (user.displayName?.trim().isNotEmpty == true)
            ? user.displayName
            : 'Volunteer',
        'pfpURL': user.photoURL ?? '',
        'TimeTracker':
            0, // int to start; make it double if you prefer fractional hours
        'role': 'High School Volunteer',
        'level': 1,
        'childrenHelped': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final existing = doc.data()!;
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!existing.containsKey('DisplayName')) {
        updates['DisplayName'] = (user.displayName?.trim().isNotEmpty == true)
            ? user.displayName
            : 'Volunteer';
      }
      if (!existing.containsKey('pfpURL')) {
        updates['pfpURL'] = user.photoURL ?? '';
      }
      if (!existing.containsKey('TimeTracker')) {
        updates['TimeTracker'] = 0;
      }
      if (updates.length > 1) await userRef.update(updates);
    }
  }
}

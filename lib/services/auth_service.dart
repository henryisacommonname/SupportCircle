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
    await ensureUserDoc(cred.user!);
    return cred;
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> updateUserProfile({
    required String displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not signed in');

    await user.updateDisplayName(displayName);
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }
    await user.reload();

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await doc.set({
      'DisplayName': displayName,
      'pfpURL': photoURL,
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
        'TimeTracker': 0,
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

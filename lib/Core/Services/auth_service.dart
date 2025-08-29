import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;


  // Email/Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // make sure their Firestore doc exists
    await ensureUserDoc(cred.user!);

    return cred.user;
  }

  // Email/Password Sign Up
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> ensureUserDoc(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(
        user.uid);

    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'displayName': user.displayName ?? 'Volunteer',
        'role': 'High School Volunteer',
        'level': 1,
        'photoUrl': user.photoURL ?? '',
        'hoursVolunteered': 0,
        'childrenHelped': 0,
      });
    }
  }
}

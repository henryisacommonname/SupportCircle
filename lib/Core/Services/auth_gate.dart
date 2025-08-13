// Bridge between Firebase authentication and the app UI
// - Decides which screen the user should see based on their log in state

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Screens/Login_Screen.dart';
import '/Home_Screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error State
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }


        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // User is not signed in
        return LoginScreen();
      },
    );
  }
}

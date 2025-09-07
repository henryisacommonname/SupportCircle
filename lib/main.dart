import 'package:draft_1/Screens/Login_Screen.dart';
import 'package:draft_1/Screens/Pfp_Editing_Screen.dart';
import 'package:draft_1/Screens/Register_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Core/Services/auth_gate.dart';
import 'firebase_options.dart';
import 'Home_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Henry App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: AuthGate(),
      routes: {
        "/login": (context) => LoginScreen(),
        "/Register": (context) => RegisterScreen(),
        "/Home": (context) => HomeScreen(),
        "/profile/edit": (context) => const ProfileEditingScreen(),
      },
    );
  }
}

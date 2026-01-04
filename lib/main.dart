import 'package:draft_1/Screens/Login_Screen.dart';
import 'package:draft_1/Screens/Pfp_Editing_Screen.dart';
import 'package:draft_1/Screens/Register_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Core/Services/auth_gate.dart';
import 'Core/Services/chatgpt_api_service.dart';
import 'Widget/Collapsable_AI_Tool.dart';
import 'firebase_options.dart';
import 'Home_Screen.dart';
import 'Screens/Resources_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    FirebaseFirestore.instance.snapshotsInSync().listen((_) {
      debugPrint('[Firestore] snapshots in sync');
    });
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ChatApiService _chatApi = ChatApiService(
    "https://ai-backend-sdmc.onrender.com",
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Henry App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: AuthGate(),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (_) => child),
            OverlayEntry(builder: (_) => CollapsibleChat(api: _chatApi)),
          ],
        );
      },
      routes: {
        "/login": (context) => LoginScreen(),
        "/Register": (context) => RegisterScreen(),
        "/Home": (context) => HomeScreen(),
        "/profile/edit": (context) => const ProfileEditingScreen(),
        ResourcesScreen.routeName: (context) => const ResourcesScreen(),
      },
    );
  }
}

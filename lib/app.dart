import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'screens/auth/auth_gate.dart';
import 'services/chat_api_service.dart';
import 'widgets/collapsible_chat.dart';

class SupportCircleApp extends StatelessWidget {
  SupportCircleApp({super.key});

  final ChatApiService _chatApi = ChatApiService(
    'https://ai-backend-sdmc.onrender.com',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SupportCircle',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthGate(),
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
      routes: AppRoutes.routes,
    );
  }
}

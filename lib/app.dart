import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/time_tracking/time_tracking_screen.dart';
import 'services/chat_api_service.dart';
import 'widgets/collapsible_chat.dart';
import 'widgets/onboarding_carousel.dart';

class SupportCircleApp extends StatelessWidget {
  SupportCircleApp({super.key});

  final ChatApiService _chatApi = ChatApiService(
    'https://ai-backend-sdmc.onrender.com',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SupportCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (_) => child),
            OverlayEntry(
              builder: (_) => StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, authSnapshot) {
                  // Only show chat FAB when user is authenticated
                  if (authSnapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  // Hide during onboarding or when add entry sheet is open
                  return ValueListenableBuilder<bool>(
                    valueListenable: isOnboardingVisible,
                    builder: (context, isOnboarding, _) {
                      if (isOnboarding) {
                        return const SizedBox.shrink();
                      }
                      return ValueListenableBuilder<bool>(
                        valueListenable: isAddEntrySheetOpen,
                        builder: (context, isSheetOpen, _) {
                          if (isSheetOpen) {
                            return const SizedBox.shrink();
                          }
                          return CollapsibleChat(api: _chatApi);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      routes: AppRoutes.routes,
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'config/app_themes.dart';
import 'config/routes.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/time_tracking/time_tracking_screen.dart';
import 'services/chat_api_service.dart';
import 'services/theme_service.dart';
import 'widgets/collapsible_chat.dart';
import 'widgets/onboarding_carousel.dart';

/// Global ThemeService instance for accessing theme across the app
final themeService = ThemeService();

class SupportCircleApp extends StatelessWidget {
  SupportCircleApp({super.key});

  final ChatApiService _chatApi = ChatApiService(
    'https://ai-backend-sdmc.onrender.com',
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final currentTheme = themeService.currentTheme;
        final themeData = themeService.themeData;

        // Build dark theme from dark config or current theme if it's dark
        final darkThemeData = currentTheme.isDark
            ? themeData
            : AppThemeBuilder.build(AppThemes.dark);

        // Build light theme from light config or current theme if it's light
        final lightThemeData = currentTheme.isDark
            ? AppThemeBuilder.build(AppThemes.light)
            : themeData;

        // Determine theme mode based on selected theme
        final themeMode = currentTheme.id == 'light'
            ? ThemeMode.light
            : currentTheme.id == 'dark'
                ? ThemeMode.dark
                : (currentTheme.isDark ? ThemeMode.dark : ThemeMode.light);

        return MaterialApp(
          title: 'SupportCircle',
          debugShowCheckedModeBanner: false,
          theme: lightThemeData,
          darkTheme: darkThemeData,
          themeMode: themeMode,
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
      },
    );
  }
}

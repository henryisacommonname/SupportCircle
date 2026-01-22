import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/profile/profile_editing_screen.dart';
import '../screens/resources/resources_screen.dart';
import '../screens/time_tracking/time_tracking_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profileEdit = '/profile/edit';
  static const String resources = '/resources';
  static const String timeTracking = '/time-tracking';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeShell(),
        profileEdit: (context) => const ProfileEditingScreen(),
        resources: (context) => const ResourcesScreen(),
        timeTracking: (context) => const TimeTrackingScreen(),
      };
}

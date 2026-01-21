import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'home_tab.dart';
import '../training/training_screen.dart';
import '../support/support_screen.dart';
import '../profile/profile_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeTab(),
    TrainingScreen(),
    SupportScreen(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SupportCircle'),
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: _currentIndex,
          onTap: (int idx) {
            setState(() => _currentIndex = idx);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Training'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Support'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

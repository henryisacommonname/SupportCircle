import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Core/Services/auth_service.dart';

class HomeTab extends statelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: []),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to SupportCircle',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'supporting children and family together',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  static const List<Widget> pages = <Widget>[
    Center(child: Text("Welcome to SupportCircle")),
    Center(child: Text("Supporting children and families together")),
    Center(child: Text("Placeholder")),
    Center(child: Text("Placeholder")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SupportCircle"),
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: index,
          onTap: (int idx) {
            setState(() => index = idx);
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman),
              label: "Training",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              label: "Support",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

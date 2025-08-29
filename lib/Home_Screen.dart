import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Core/Services/auth_service.dart';
import '/Screens/Home_Tab.dart';
import 'screens/Profile_Tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  static const List<Widget> pages = <Widget>[
    HomeTab(),
    Center(child: Text("Supporting children and families together")),
    Center(child: Text("Placeholder")),
    ProfileTab(),
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

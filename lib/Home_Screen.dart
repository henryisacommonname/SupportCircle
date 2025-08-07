import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Core/Services/auth_service.dart';

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
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}

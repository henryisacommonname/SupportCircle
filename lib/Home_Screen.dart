import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Core/Services/auth_service.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});
  @override
  State<Home_Screen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home_Screen> {
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

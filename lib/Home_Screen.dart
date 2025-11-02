import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Core/Services/auth_service.dart';
import '/Screens/Home_Tab.dart';
import 'screens/Profile_Tab.dart';
import 'screens/Training_Screen.dart';
import 'screens/Support_Screen.dart';
import 'Core/Services/chatgpt_API_service.dart';
import 'Widget/Collapsable_AI_Tool.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

//TAB NAVIGATOR
class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final _Chat_API = Chat_API(
    "https://a23e4be5-1075-4548-baf7-22e80ab91722-00-f46fp7e8sg7i.worf.replit.dev/",
  );
  static const List<Widget> pages = <Widget>[
    HomeTab(),
    TrainingScreen(),
    SupportScreen(),
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
      body: Stack(
        children: [
          pages[index],
          Align(
            alignment: Alignment.centerRight,
            child: collapsible_Chat(api: _Chat_API),
          ),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:draft_1/Screens/login_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
  return MaterialApp(
    title: "Henrysproject",
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: loginscreen(
      onRegisterTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('register')));
      },
    ),
  );
  }
}
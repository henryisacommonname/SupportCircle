import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class loginscreen extends StatefulWidget {
  // final VoidCallback onRegisterTap;
  // TODO const LoginScreen ({required this.onRegisterTap});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginscreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext ctx) => Scaffold(
    appBar: AppBar(title: const Text("Log In")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: "Email Address"),
          ),
          TextField(
            controller: _passCtrl,
            decoration: const InputDecoration(labelText: "Password"),
          ),
        ],
      ),
    ),
  );
}

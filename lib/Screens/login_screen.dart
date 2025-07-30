import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class loginscreen extends StatefulWidget {
  // final VoidCallback onRegisterTap;
  // TODO const LoginScreen ({required this.onRegisterTap});
  final VoidCallback onRegisterTap;
  const loginscreen({Key? key,required this.onRegisterTap}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginscreen> {
  final _auth = AuthService();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _errormessage;
  bool _isloading=false;

  Future<void> _sign_in() async {
    setState(() {
      _isloading=true;
      _errormessage=null;
    });

    try {
      await _auth.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errormessage = e.message);
    }
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    appBar: AppBar(title: const Text("Log In")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: "Email Address",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          TextField(
            controller: _passCtrl,
            decoration: const InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
              width:12,
              //TODO sign-in
              child: ElevatedButton(
                  onPressed: _sign_in,
                  child: const Text("Sign In"))
          ),
          TextButton(
              onPressed: widget.onRegisterTap,
              child: const Text("Register"))
        ],

        //sign-in button
      ),
    ),
  );
}

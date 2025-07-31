import 'package:flutter/material.dart';
import '../Services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isloading = false;

  Future<void> _Register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isloading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerWithEmail(email, password);
      // Authgate will auto-redirect
    } catch (e) {
      setState(() {
        _errorMessage = "Register failed: ${e.toString()}";
      });
    } finally {
      setState(() => _isloading = false);
    }
  }

  void _GotoLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            _isloading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _Register,
                    child: const Text('Register'),
                  ),
            TextButton(
              onPressed: _GotoLogin,
              child: const Text("Already have an account?"),
            ),
          ],
        ),
      ),
    );
  }
}

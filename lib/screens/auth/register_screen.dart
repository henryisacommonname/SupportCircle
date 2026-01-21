import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

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
  bool _isLoading = false;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerWithEmail(email, password);
      // AuthGate will auto-redirect
    } catch (e) {
      setState(() {
        _errorMessage = 'Register failed: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToLogin() {
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
              decoration: const InputDecoration(labelText: 'Email'),
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
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
            TextButton(
              onPressed: _goToLogin,
              child: const Text('Already have an account?'),
            ),
          ],
        ),
      ),
    );
  }
}

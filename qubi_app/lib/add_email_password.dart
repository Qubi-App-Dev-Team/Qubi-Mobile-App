import 'package:flutter/material.dart';
import 'package:qubi_app/pages/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEmailPasswordScreen extends StatefulWidget {
  final User user;
  const AddEmailPasswordScreen({super.key, required this.user});

  @override
  State<AddEmailPasswordScreen> createState() => _AddEmailPasswordScreenState();
}

class _AddEmailPasswordScreenState extends State<AddEmailPasswordScreen> {
  late TextEditingController emailController;
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill the email field with the user's email if available
    emailController = TextEditingController(text: widget.user.email ?? '');
  }

  Future<void> _linkEmailPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final credential = EmailAuthProvider.credential(email: email, password: password);

    try {
      await widget.user.linkWithCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password linked successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        errorMessage = 'This email is already linked to another account.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password should be at least 6 characters.';
      } else {
        errorMessage = e.message;
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Email & Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add an email and password to your account:',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              readOnly: true, // Email field is read-only
              decoration: const InputDecoration(
                labelText: 'Email',
                suffixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _linkEmailPassword,
                    child: const Text('Link Account'),
                  ),
          ],
        ),
      ),
    );
  }
}

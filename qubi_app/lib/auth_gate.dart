import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qubi_app/add_email_password.dart';
import 'package:qubi_app/pages/home/home.dart';
import 'widget_tree.dart'; // widget tree for auth

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Not signed in → show login page
        if (!snapshot.hasData) {
          return const WidgetTree(); // Your firebase_ui_auth sign-in screen
        }

        final user = snapshot.data!;
        final providerIds = user.providerData.map((p) => p.providerId).toList();

        // If Google login only → force link email/password
        final googleOnly = providerIds.contains('google.com') && !providerIds.contains('password');

        if (googleOnly) {
          return AddEmailPasswordScreen(user: user);
        } else {
          return const HomePage();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:qubi_app/components/nav_bar.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

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
          return SignInScreen(
            providers: [
              EmailAuthProvider(), 
              GoogleProvider(
                clientId: switch (defaultTargetPlatform) {
                  TargetPlatform.iOS => dotenv.env['IOS_CLIENT_ID'] ?? '',
                  TargetPlatform.macOS => dotenv.env['IOS_CLIENT_ID'] ?? '',
                  TargetPlatform.android => '', // ✅ empty string instead of null
                  _ => dotenv.env['GOOGLE_CLIENT_ID'] ?? '',
                },
              ),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/qubi_ball.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to Qubi App, please sign in!')
                    : const Text('Welcome to Qubi App, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
              sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/qubi_gate.png'),
                ),
              );
            },
          );
        }
        return const NavBar();
      },
    );
  }
}

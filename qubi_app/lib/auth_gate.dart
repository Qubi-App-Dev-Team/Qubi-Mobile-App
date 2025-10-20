import 'package:flutter/material.dart';
import 'package:qubi_app/add_email_password.dart';
import 'package:qubi_app/pages/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
            providers: [EmailAuthProvider(), GoogleProvider(clientId: dotenv.env['GOOGLE_CLIENT_ID'] ?? '')],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/qubi_logo.png'),
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
                  child: Image.asset('assets/images/qubi_logo.png'),
                ),
              );
            },                           
          );                                                           
        }

        final user = snapshot.data!;
        final providerIds = user.providerData.map((p) => p.providerId).toList();

        // If Google login only → force link email/password
        final googleOnly = providerIds.contains('google.com') && !providerIds.contains('password');
        final passwordOnly = providerIds.contains('password') && !providerIds.contains('google.com');

        if (googleOnly) {
          return AddEmailPasswordScreen(user: user);
        } else if (passwordOnly) { 
          print("add option for adding google log in too");
          return const HomePage();
        } else {
          return const HomePage();
        }

      },
    );
  }
}

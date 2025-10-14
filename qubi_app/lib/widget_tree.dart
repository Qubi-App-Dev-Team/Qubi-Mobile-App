import 'package:flutter/material.dart';
import 'package:qubi_app/auth.dart';
import 'package:qubi_app/pages/home/login.dart';
import 'package:qubi_app/pages/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree ({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
    Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(                                         
            providers: [EmailAuthProvider()],
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

          );                                                           
        }

        return const HomePage();
      },
    );
  }

  // Widget build(BuildContext context) {
  //   return StreamBuilder<User?>(
  //     stream: Auth().authStateChanges,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.active) {
  //         final User? user = snapshot.data;
  //         return user == null ? const LoginPage() : const HomePage();
  //       } else {
  //         return const Scaffold(
  //           body: Center(
  //             child: CircularProgressIndicator(),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }
}

import 'package:flutter/material.dart';
import 'components/nav_bar.dart'; // navigation bar
import 'auth_gate.dart'; // widget tree for auth
import 'package:firebase_core/firebase_core.dart'; // firebase core
import 'firebase_options.dart'; // firebase options
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv for env variables

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //dont show debug flag
      title: 'Qubi App',
      theme: ThemeData(
        //default color scheme - can change later
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Use Strawford as default text
        fontFamily: 'Strawford',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Strawford'),
          bodyMedium: TextStyle(fontFamily: 'Strawford'),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// THIS MIGHT WORK I HAVE TO GET SIGN IN AND CLEANING UP WORK + THE EDGE CASE FROM CHAT HOLY SHIT
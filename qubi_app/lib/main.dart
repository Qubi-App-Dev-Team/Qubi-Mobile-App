import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // firebase core
import 'firebase_options.dart'; // firebase options
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv for env variables
import 'package:flutter/foundation.dart';
import 'package:qubi_app/auth_gate.dart'; // auth gate
import 'package:qubi_app/pages/learn/bloc/chapter_data_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final clientId = switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => dotenv.env['IOS_CLIENT_ID'] ?? '',
    TargetPlatform.android => '', // Android uses google-services.json instead
    _ => dotenv.env['GOOGLE_CLIENT_ID'] ?? '', // Web or others
  };
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  ChapterDataStore.refreshChaptersCache(includeDocId: false);
  runApp(MyApp(clientId: clientId));
}

class MyApp extends StatelessWidget {
  final String clientId;

  const MyApp({super.key, required this.clientId});

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
      home: AuthGate(clientId: clientId),
    );
  }
}
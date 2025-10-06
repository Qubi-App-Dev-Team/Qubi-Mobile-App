import 'package:flutter/material.dart';
import 'pages/story/story_page.dart'; // make sure this file exists in lib/

void main() {
  runApp(const MyApp());
}

/// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qubi App Demo',
      debugShowCheckedModeBanner: false, // remove the debug banner
      theme: ThemeData(
        brightness: Brightness.light, // force light mode
        primarySwatch: Colors.blue,
      ),
      home: const StoryPage(), // start with your StoryPage
    );
  }
}

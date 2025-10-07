import 'package:flutter/material.dart';
import 'components/nav_bar.dart'; // navigation bar

void main() {
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
      home: const NavBar(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:qubi/core/main_navigation_screen.dart';
import 'package:qubi/dependency_injection.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCoreDI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qubi',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}



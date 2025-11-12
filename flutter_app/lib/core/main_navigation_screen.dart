import 'package:flutter/material.dart';
import 'package:qubi/features/devices/presentation/devices_screen.dart';
import '../features/settings/settings.dart';
import '../features/lessons/lessons.dart';
import '../features/social/social.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    DevicesScreen(),
    LessonsScreen(),
    SocialScreen(),
    SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.circle_outlined),
      label: 'Qubi',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school),
      label: 'Lessons',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Social',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navigationItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
} 
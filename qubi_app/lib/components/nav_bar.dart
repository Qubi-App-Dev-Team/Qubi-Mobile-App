import 'package:flutter/material.dart';
import '../pages/home/qubis_page.dart'; //home page
import '../pages/learn/learn_page.dart'; //learning page
import '../pages/profile/profile_page.dart'; //user profile page

//Mobile app bottom navigation bar
class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0; //index of _pages to nav to

  // List of pages possible to navigate to
  final List<Widget> _pages = const [
    QubisPage(), //home
    LearnPage(),
    ProfilePage(),
  ];

  // Navigate to page when a tab is clicked
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Light up the icon with gradient colors when selected
  Widget _buildIcon(IconData icon, bool isSelected) {
    if (isSelected) { 
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            //colors retrieved from Figma brand palette
            colors: [Color(0xFF6525FE), Color(0xFF1A91FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.circle, color: Colors.white, size: 18),
      );
    } else {
      return Icon(icon, color: Colors.black54);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [ //icons in the navigation bar
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.circle_outlined, _selectedIndex == 0),
              label: 'Qubis',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.menu_book_outlined, _selectedIndex == 1),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person_outline, _selectedIndex == 2),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

}
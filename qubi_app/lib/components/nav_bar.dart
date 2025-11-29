import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pages/home/home.dart'; //home page
import '../pages/learn/pages/all_chapters_page.dart'; //learning page
import '../pages/profile/pages/profile.dart'; //user profile page

//Mobile app bottom navigation bar
class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0; //index of _pages to nav to

  // List of pages possible to navigate to
  final List<Widget> _pages = [
    HomePage(), //home
    const AllChaptersPage(),
    const ProfilePage(),
  ];

  // Image icons for each page
  final List<Map<String, String>> _iconPaths = [
    {
      'normal': 'assets/images/home_icon.svg',
      'active': 'assets/images/home_gradient_icon.svg',
    },
    {
      'normal': 'assets/images/learn_icon.svg',
      'active': 'assets/images/learn_gradient_icon.svg',
    },
    {
      'normal': 'assets/images/profile_icon.svg',
      'active': 'assets/images/profile_gradient_icon.svg',
    },
  ];

  // Navigate to page when a tab is clicked
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // default height of kBottomNavigationBarHeight is 56, then subtract some
    double navBarHeight = kBottomNavigationBarHeight - 8;
    double iconWidth = navBarHeight * 75 / 44; // maintain aspect ratio

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: List.generate(_iconPaths.length, (index) {
          return BottomNavigationBarItem(
            //icon is lit up if selected, else is not
            icon: SvgPicture.asset(
              _selectedIndex == index
                  ? _iconPaths[index]['active']!
                  : _iconPaths[index]['normal']!,
              height: navBarHeight,
              width: iconWidth,
            ),
            label: '',
          );
        }),
      ),
    );
  }
}

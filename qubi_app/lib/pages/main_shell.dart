import 'package:flutter/material.dart';

// Imports for each page (tab)
import 'package:qubi_app/pages/home/home.dart';
import 'package:qubi_app/pages/learn/learn.dart';
import 'package:qubi_app/pages/profile/profile.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Keeps track of which tab is currently selected (0 = Qubis, 1 = Learn, 2 = Profile)
  int _selectedIndex = 0;

  // These are the pages that appear when switching tabs ()
  final List<Widget> _pages = const [
    HomePage(),
    LearnPage(),
    ProfilePage(),
  ];

  // Updates which tab is selected
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF8),
      body: _pages[_selectedIndex], // Displays the active page

      // BOTTOM NAVIGATION BAR SECTION
      bottomNavigationBar: Container(
        height: 95, // total height of the nav bar (container + bar itself)
        decoration: const BoxDecoration(
          color: Color(0xFFE6EEF8),
          border: Border(
            top: BorderSide(
              color: Color(0xFFC7DDF0), // thin blue divider line above bar
              width: 1.5,
            ),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 330, // controls horizontal spacing between the 3 tabs
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: const Color(0xFFE6EEF8),
                height: 80, // controls internal height of the Material nav bar
                indicatorColor: Colors.white, // white "pill" behind selected tab
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // roundness of pill
                ),

                // Controls label (text) style for selected vs. unselected
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                  if (states.contains(WidgetState.selected)) {
                    // gradient text for selected label
                    final Shader linearGradient = const LinearGradient(
                      colors: <Color>[
                        Color(0xFF6525FE), // purple
                        Color(0xFF4AD2FF), // lighter blue
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ).createShader(const Rect.fromLTWH(0, 0, 60, 40));

                    return TextStyle(
                      fontSize: 14, // text size for selected label
                      fontWeight: FontWeight.w800,
                      foreground: Paint()..shader = linearGradient, // gradient text color
                    );
                  }
                  return const TextStyle(
                    fontSize: 14, // text size for unselected label
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // text color for unselected label
                  );
                }),
              ),

              // Main navigation bar
              child: NavigationBar(
                backgroundColor: Colors.transparent, // lets parent Container color show
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped, // updates selected tab on tap
                destinations: [
                  // Each destination = 1 tab
                  _buildDestination(
                    index: 0,
                    icon: Icons.circle_outlined,
                    label: 'Qubis',
                  ),
                  _buildDestination(
                    index: 1,
                    icon: Icons.menu_book_outlined,
                    label: 'Learn',
                  ),
                  _buildDestination(
                    index: 2,
                    icon: Icons.person_outline,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method: builds each tab destination
  NavigationDestination _buildDestination({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return NavigationDestination(
      icon: isSelected
          ? GradientIcon(
              icon: icon,
              colors: const [Color(0xFF6525FE), Color(0xFFEA3076)],
              size: 26, // icon size
            )
          : Icon(icon, color: Colors.black, size: 26), // unselected icon style
      label: label, // text label under each icon
    );
  }
}

// Custom widget: GradientIcon for selected tab icons
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 25,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors, // gradient colors for selected icon
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcATop, // ensures icon is visible over white pill
      child: Icon(icon, size: size, color: Colors.black), // base icon color
    );
  }
}

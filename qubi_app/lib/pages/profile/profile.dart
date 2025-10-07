// pages/profile/profile.dart
import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:qubi_app/pages/profile/components/theme_widgets.dart';
import 'package:qubi_app/pages/profile/components/setting_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: AppBackdrop()),

        Scaffold(
          // Scaffold contains app bar and body
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 16,
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: false,
            actions: [
              Opacity(
                opacity: 0.85,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    icon: Center(
                      child: SvgPicture.asset(
                        // edit button
                        'assets/images/Edit.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height:
                    1 /
                    MediaQuery.of(context).devicePixelRatio, // true hairline
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),

          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              // profile page content
              children: const [
                ProfileCard(), // avatar, name, email
                SizedBox(height: 16),
                // below items are on seperate pages for clarity
                ThemeCollectionCard(), // theme selection
                SizedBox(height: 16),
                SettingsSection(), // settings list
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundImage: AssetImage('assets/images/Picture.png'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bucky Qzdemir',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Bucky@qolour.io',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

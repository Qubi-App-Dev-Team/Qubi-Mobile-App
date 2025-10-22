// pages/profile/profile.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubi_app/pages/profile/pages/exec_history.dart';
import 'package:qubi_app/pages/profile/pages/default_settings.dart';
import 'package:qubi_app/pages/profile/components/theme_selector.dart';

Future<void> openExternal(String url) async {
  final uri = Uri.parse(url);
  final ok = await canLaunchUrl(uri);
  if (!ok) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

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
  const ProfileCard({super.key});

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

class ThemeCollectionCard extends StatefulWidget {
  const ThemeCollectionCard({super.key});

  @override
  State<ThemeCollectionCard> createState() => _ThemeCollectionCardState();
}

class _ThemeCollectionCardState extends State<ThemeCollectionCard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your theme collection',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
              ),
              const Spacer(),
              Text(
                '6/20',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ThemeSelector(
            selectedIndex: selectedIndex,
            onSelect: (i) => setState(() => selectedIndex = i),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        // list of settings -- all need subpages.
        children: [
          // 1) Execution history
          SettingTile(
            svgAsset: 'assets/images/Clock.svg',
            title: 'Execution history',
            subtitle: 'See all your quantum computer runs.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExecHistoryPage()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFECECEC)),

          // 2) Default Qubi settings
          SettingTile(
            svgAsset: 'assets/images/Settings.svg',
            title: 'Default Qubi settings',
            subtitle: 'Adjust your default settings.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DefaultSettingsPage()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFECECEC)),

          // 3) Support
          SettingTile(
            svgAsset: 'assets/images/Info.svg', // ← matches your repo
            title: 'Support',
            subtitle: 'Get help or contact us.',
            onTap: () => openExternal('https://www.qolour.io/'),
          ),
          Divider(height: 1, color: Color(0xFFECECEC)),
          SettingTile(
            svgAsset: 'assets/images/Info.svg',
            title: 'Learn more quantum',
            subtitle: 'Resources, events, and communities at qolour.io',
            onTap: () => openExternal('https://www.qolour.io/'),
          ),
        ],
      ),
    );
  }
}
// Requires: import 'package:flutter_svg/flutter_svg.dart';

/// A single settings row with an SVG icon, text, and trailing chevron.
class SettingTile extends StatelessWidget {
  final String title; // main label
  final String subtitle; // supporting text
  final String svgAsset; // path to asset SVG
  final VoidCallback? onTap;

  const SettingTile({
    required this.title,
    required this.subtitle,
    required this.svgAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ← wrap the tile so it’s tappable
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // leading icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgAsset,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.65),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // main text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // right arrow icon
            const Icon(Icons.chevron_right, size: 26),
          ],
        ),
      ),
    );
  }
}

/// Shared container style used for cards on the profile screen.
BoxDecoration cardDecoration() => BoxDecoration(
  color: Colors.white.withValues(alpha: 0.9),
  borderRadius: BorderRadius.circular(22),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ],
  border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
);

/// Small SVG icon wrapper for BottomNavigationBar items.
class SvgBarIcon extends StatelessWidget {
  final String asset;
  final Color color;

  const SvgBarIcon(this.asset, {required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

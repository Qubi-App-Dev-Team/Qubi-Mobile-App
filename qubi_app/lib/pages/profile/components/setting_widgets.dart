import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        // list of settings -- all need subpages.
        children: const [
          SettingTile(
            svgAsset: 'assets/images/Clock.svg', // path to your svg
            title: 'Execution history', // main title
            subtitle: 'See all your quantum computer runs.', // subtitle
          ),
          Divider(height: 1, color: Color(0xFFECECEC)),
          SettingTile(
            svgAsset: 'assets/images/Settings.svg',
            title: 'Default Qubi settings',
            subtitle: 'Adjust your default settings.',
          ),
          Divider(height: 1, color: Color(0xFFECECEC)),
          SettingTile(
            svgAsset: 'assets/images/Info.svg',
            title: 'About Qubi',
            subtitle: 'Learn about how Qubi came to be.',
          ),
          Divider(height: 1, color: Color(0xFFECECEC)),
          SettingTile(
            svgAsset: 'assets/images/Info.svg',
            title: 'Learn more quantum',
            subtitle: 'Resources, events, and communities at qolour.io',
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

  const SettingTile({
    super.key, 
    required this.title,
    required this.subtitle,
    required this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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

  const SvgBarIcon(this.asset, {super.key, required this.color});

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

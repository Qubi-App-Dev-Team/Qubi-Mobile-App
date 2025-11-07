import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemeCollectionCard extends StatefulWidget {
  const ThemeCollectionCard({super.key});

  @override
  State<ThemeCollectionCard> createState() => _ThemeCollectionCardState();
}

class _ThemeCollectionCardState extends State<ThemeCollectionCard> {
  // 1..6 — set the default selected dot here
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      // white border will be white.
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0x190B1521),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                // Header
                'Your theme collection',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
              ),
              const Spacer(),
              Text(
                // Right side text - shows count of options listed.
                '6/20',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(6, (i) {
                final idx = i + 1; // 1..6
                return _ThemeDotSvg(
                  index: idx,
                  selected: _selectedIndex == idx,
                  onTap: () => setState(() => _selectedIndex = idx),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeDotSvg extends StatelessWidget {
  final int index; // 1..6
  final bool selected;
  final VoidCallback? onTap;

  const _ThemeDotSvg({
    required this.index,
    this.selected = false,
    this.onTap,
  }); // images are pulled from assets/images/ folder.

  @override
  Widget build(BuildContext context) {
    // base case image.
    final assetName =
        'assets/images/themedot$index${selected ? 'selected' : ''}.svg';

    // on click -> change which element has an check mark on it (selected).
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // Changing image to one with check mark if selected.
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 45.17,
        height: 46.5,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          assetName,
          width: 45.17,
          height: 46.5,
          fit: BoxFit.contain,
          semanticsLabel: 'Theme dot $index ${selected ? 'selected' : ''}',
        ),
      ),
    );
  }
}

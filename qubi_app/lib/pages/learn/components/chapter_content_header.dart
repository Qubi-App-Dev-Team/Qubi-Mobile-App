import 'package:flutter/material.dart';

/// Transparent header for the Chapter Content page.
/// Left: "<" back button + "All Chapters"
/// Right: 3-dots button (no-op for now).
///
/// Back behavior:
/// - If there's a page to pop to, it pops (back to all_chapters_page if you came from there).
/// - If not (deeplink, first page), it tries to navigate to '/all_chapters'.

class ChapterContentHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMore; // optional, no functionality for now

  const ChapterContentHeader({super.key, this.onMore});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleBack(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    if (canPop) {
      Navigator.of(context).pop();
    } else {
      // Fallback route if opened directly/deeplinked
      Navigator.of(context).pushReplacementNamed('/all_chapters_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.transparent, // let the SVG backdrop show through
        child: Row(
          children: [
            // Back "<" + label
            InkWell(
              onTap: () => _handleBack(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.chevron_left, size: 30),
                    SizedBox(width: 5),
                    Text(
                      'All Chapters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 3 dots (no functionality for now)
            IconButton(
              onPressed: onMore, // can be null; no-op for now
              icon: const Icon(Icons.more_horiz),
              tooltip: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
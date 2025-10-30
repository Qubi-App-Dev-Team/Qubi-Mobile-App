import 'package:flutter/material.dart';

//Header component for section pages
//Backwards navigation + 3 dots pages

class SectionContentHeader extends StatelessWidget implements PreferredSizeWidget {
  final int chapterNumber;

  const SectionContentHeader({super.key, required this.chapterNumber});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _formatChapterNumber(int n) => n < 10 ? '0$n' : '$n';

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            InkWell(
              onTap: () => _handleBack(context),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.chevron_left, size: 28),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Chapter ${_formatChapterNumber(chapterNumber)}',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: null, // can add callback later
              icon: const Icon(Icons.more_horiz),
              tooltip: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

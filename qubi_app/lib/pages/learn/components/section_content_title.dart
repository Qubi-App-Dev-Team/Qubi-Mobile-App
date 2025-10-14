import 'package:flutter/material.dart';

//Title bar component for section content page
//Contains chapter title + section title
class SectionContentTitle extends StatelessWidget {
  final String chapterTitle;
  final String sectionTitle;

  const SectionContentTitle({
    super.key,
    required this.chapterTitle,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    // light grey frame and darker center area, same structure as chapter title
    const lightBorder = Color(0xFFF3F7FC);
    const centerBg   = Color(0xFFE6EEF8);

    return Container(
      color: lightBorder,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        color: centerBg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // chapter title (smaller, now black)
            Text(
              chapterTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // section title (larger and bold)
            Text(
              sectionTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';

//Title component for individual chapter pages
class ChapterContentTitle extends StatelessWidget {
  final Chapter chapter;

  const ChapterContentTitle({super.key, required this.chapter});

  String _formatChapterNumber(int n) => n < 10 ? '0$n' : '$n';

  @override
  Widget build(BuildContext context) {
    // Light grey “border” color (outside)
    const lightBorder = Color(0xFFF3F7FC);
    // Slightly darker center panel
    const centerBg   = Color(0xFFE6EEF8);
    const numberBlue = Color(0xFF1B9CFC);

    return Container(
      // OUTER: fills width; becomes the light grey border area
      color: lightBorder,
      // Set how thick the “borders” look by adjusting vertical margin of the inner block
      child: Container(
        // INNER: slightly smaller, so the light grey shows above/below as borders
        margin: const EdgeInsets.symmetric(vertical: 2), // ← border thickness
        color: centerBg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter number (with leading zero) in blue
            Text(
              'Chapter ${_formatChapterNumber(chapter.number)}',
              style: const TextStyle(
                color: numberBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // Chapter title, bold black
            Text(
              chapter.title,
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
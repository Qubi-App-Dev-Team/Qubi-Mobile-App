import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/components/gradient_progress_bar.dart';
import 'package:qubi_app/pages/learn/components/info_badge.dart';

// Box containing title, short description, and progress for subtopics within a chapter
class ChapterContentBox extends StatelessWidget {
  final String title;
  final String description;
  final double progress; // 0..1
  final bool locked;

  const ChapterContentBox({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.locked,
  });

  static const _lockedOrange = Color(0xFFF46A1E);

@override
Widget build(BuildContext context) {
  const gap = 8.0; // uniform vertical spacing
  final clamped = progress.clamp(0.0, 1.0);
  final percentText = 'Progress: ${(clamped * 100).round()}% Completed';

  return Material(
    color: Colors.white,
    elevation: 1,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.more_horiz),
                tooltip: 'More',
              ),
            ],
          ),

          if (!locked) ...[
            const SizedBox(height: gap),
            Text(
              percentText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: gap),
            GradientProgressBar(value: clamped),
            const SizedBox(height: gap),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ] else ...[
            const SizedBox(height: gap),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: gap),
            InfoBadge(
              leading: const Icon(Icons.lock, size: 16, color: Colors.white),
              label: 'Locked',
              backgroundColor: _lockedOrange,
              labelColor: Colors.white,
              borderColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ],
        ],
      ),
    ),
  );
}

}

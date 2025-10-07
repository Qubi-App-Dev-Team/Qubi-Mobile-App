import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/components/info_badge.dart';
import 'package:qubi_app/pages/learn/components/gradient_progress_bar.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/pages/chapter_content_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

//Widget for all chapters page which shows information about an individual chapter (see class fields for more)
class ChapterInfo extends StatelessWidget {
  final Chapter chapter;        // contains chapter number + title
  final double progress;        // 0.0..1.0
  final String difficulty;      // "beginner" | "intermediate" | "advanced"
  final int skinsUnlocked;      // 0..2
  final bool locked;            // whether chapter is locked

  const ChapterInfo({
    super.key,
    required this.chapter,
    required this.progress,
    required this.difficulty,
    required this.skinsUnlocked,
    this.locked = false,
  });

  static const _lightBadge = Color(0xFFE6EEF8); // skill & skins badge color
  static const _lockedOrange = Color(0xFFF46A1E); // locked badge color

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentText = '${(clampedProgress * 100).round()}% progress';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      clipBehavior: Clip.antiAlias, // ensures ripple stays within rounded corners
      child: InkWell(
        onTap: () {
          if (locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You haven't unlocked this chapter yet!"),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChapterContentPage(chapter: chapter),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row: Chapter number + (optional) Locked badge + more button
              Row(
                children: [
                  Text(
                    'Chapter 0${chapter.number}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1B9CFC)
                    ),
                  ),
                  if (locked) ...[
                    const SizedBox(width: 8),
                    InfoBadge(
                      leading: const Icon(Icons.lock, size: 14, color: Colors.white),
                      label: 'Locked',
                      backgroundColor: _lockedOrange,
                      labelColor: Colors.white,
                      borderColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: null, // no functionality yet
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Chapter title
              Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              /// Progress section (only for unlocked chapters)
              if (!locked) ...[
                Text(
                  percentText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GradientProgressBar(value: clampedProgress),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 6),

              /// Bottom badges: Difficulty + Skins
              Row(
                children: [
                  InfoBadge(
                    leading: SvgPicture.asset(
                      'assets/images/${difficulty.toLowerCase()}_icon.svg',
                      width: 18,
                      height: 18,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.error, size: 16),
                    ),
                    label: _capitalize(difficulty),
                    backgroundColor: _lightBadge,
                    labelColor: Colors.black87,
                    borderColor: Colors.transparent,
                  ),
                  const SizedBox(width: 10),
                  InfoBadge(
                    leading: SvgPicture.asset(
                      'assets/images/skins_icon.svg',
                      width: 18,
                      height: 18,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.style, size: 16),
                    ),
                    label: 'Skins $skinsUnlocked/2',
                    backgroundColor: _lightBadge,
                    labelColor: Colors.black87,
                    borderColor: Colors.transparent,
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
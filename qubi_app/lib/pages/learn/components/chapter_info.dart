import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:qubi_app/pages/learn/components/gradient_progress_bar.dart';
import 'package:qubi_app/pages/learn/components/info_badge.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/pages/chapter_content_page.dart';
import 'package:qubi_app/user_bloc/stored_user_info.dart';

/// Card for a single chapter on the All Chapters page.
/// Now fully reactive via StoredUserInfo ValueNotifiers:
/// - locked state (chapterLockedVN)
/// - chapter progress (chapterProgressVN)
/// - skins unlocked count (chapterSkinsUnlockedVN)
class ChapterInfo extends StatelessWidget {
  final Chapter chapter; // number + title

  const ChapterInfo({
    super.key,
    required this.chapter,
  });

  static const _lightBadge = Color(0xFFE6EEF8); // skill & skins badge color
  static const _lockedOrange = Color(0xFFF46A1E); // locked badge color
  static const _sectionBlue = Color(0xff1B9CFC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      clipBehavior: Clip.antiAlias, // ripple stays within rounded corners
      child: InkWell(
        onTap: () async {
          // Capture navigator before any await (avoid context across async gaps)
          final navigator = Navigator.of(context);

          // Read the latest locked value from the notifier (fallback to false)
          final locked = StoredUserInfo.chapterLockedVN.value[chapter.number] ?? true;

          if (locked) {
            final proceed = await _confirmProceedDialog(context);
            if (proceed != true) return;
          }
          if (!navigator.mounted) return;
          await navigator.push(
            MaterialPageRoute(
              builder: (_) => ChapterContentPage(chapter: chapter),
            ),
          );
          if (locked) {await StoredUserInfo.setChapterLocked(chapterNum: chapter.number, locked: false);}
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row: "Chapter 0x" + (reactive) Locked badge + more button
              Row(
                children: [
                  Text(
                    'Chapter 0${chapter.number}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _sectionBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reactive Locked badge
                  ValueListenableBuilder<Map<int, bool>>(
                    valueListenable: StoredUserInfo.chapterLockedVN,
                    builder: (_, lockedMap, _) {
                      final locked = lockedMap[chapter.number] ?? false;
                      if (!locked) return const SizedBox.shrink();
                      return InfoBadge(
                        leading:
                            const Icon(Icons.lock, size: 14, color: Colors.white),
                        label: 'Locked',
                        backgroundColor: _lockedOrange,
                        labelColor: Colors.white,
                        borderColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      );
                    },
                  ),
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

              /// Progress (reactive) — only when unlocked
              ValueListenableBuilder<Map<int, bool>>(
                valueListenable: StoredUserInfo.chapterLockedVN,
                builder: (_, lockedMap, _) {
                  final locked = lockedMap[chapter.number] ?? false;
                  if (locked) {
                    // Keep vertical rhythm similar to your original
                    return const SizedBox(height: 6);
                  }

                  return ValueListenableBuilder<Map<int, double>>(
                    valueListenable: StoredUserInfo.chapterProgressVN,
                    builder: (_, progressMap, _) {
                      final p = (progressMap[chapter.number] ?? 0.0).clamp(0.0, 1.0);
                      final percentText = '${(p * 100).round()}% progress';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            percentText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GradientProgressBar(value: p),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  );
                },
              ),

              /// Bottom badges: Difficulty + (reactive) Skins
              Row(
                children: [
                  InfoBadge(
                    leading: SvgPicture.asset(
                      'assets/images/${chapter.difficulty.toLowerCase()}_icon.svg',
                      width: 18,
                      height: 18,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.error, size: 16),
                    ),
                    label: _capitalize(chapter.difficulty),
                    backgroundColor: _lightBadge,
                    labelColor: Colors.black87,
                    borderColor: Colors.transparent,
                  ),
                  const SizedBox(width: 10),

                  // Reactive skins count
                  ValueListenableBuilder<Map<int, int>>(
                    valueListenable: StoredUserInfo.chapterSkinsUnlockedVN,
                    builder: (_, skinsMap, _) {
                      final count = skinsMap[chapter.number] ?? 0;
                      return InfoBadge(
                        leading: SvgPicture.asset(
                          'assets/images/skins_icon.svg',
                          width: 18,
                          height: 18,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.style, size: 16),
                        ),
                        label: 'Skins $count/2',
                        backgroundColor: _lightBadge,
                        labelColor: Colors.black87,
                        borderColor: Colors.transparent,
                      );
                    },
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

  /// Locked confirmation dialog
  Future<bool?> _confirmProceedDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Proceed to locked chapter?'),
        content: const Text(
          "You haven't met the prerequisites for this chapter yet. "
          'Are you sure you would like to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

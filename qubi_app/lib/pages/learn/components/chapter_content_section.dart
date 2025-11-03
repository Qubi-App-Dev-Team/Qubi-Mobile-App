import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/pages/section_content_page.dart';
import 'package:qubi_app/pages/learn/components/gradient_progress_bar.dart';
import 'package:qubi_app/pages/learn/components/info_badge.dart';
import 'package:qubi_app/pages/learn/models/renderer.dart';
import 'package:qubi_app/pages/learn/bloc/chapter_data_store.dart';
import 'package:qubi_app/user_bloc/stored_user_info.dart';

/// A simplified vertical list of section modules for a chapter (no difficulty groups).
/// Each tile shows:
///  - Top row:  "Section x.y" (blue)  ...  [more (3-dots) button]
///  - Title
///  - UNLOCKED: progress text + bar, then the 2-line description
///  - LOCKED:   2-line description, then orange Locked badge bottom-left
class ChapterContentSection extends StatefulWidget {
  final Chapter chapter;
  final List<ChapterContent> items;

  const ChapterContentSection({
    super.key,
    required this.chapter,
    required this.items,
  });

  @override
  State<ChapterContentSection> createState() => _ChapterContentSectionState();
}

class _ChapterContentSectionState extends State<ChapterContentSection> {
  static const double _hPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPadding),
      child: Column(
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            _SectionTile(
              chapter: widget.chapter,
              item: widget.items[i],
              sectionIndexFallback: i + 1,
              onOpen: (chapter, content) async {
                // Capture navigator BEFORE any await to avoid using context across async gaps.
                final navigator = Navigator.of(context);

                // Determine actual section number
                final int chapterNum = chapter.number;
                final int sectionNum =
                    (content.number != 0) ? content.number : (widget.items.indexOf(content) + 1);

                // Reactive lock value (string key: "chapter.section")
                final String lockKey = '$chapterNum.$sectionNum';
                final bool isLocked =
                    StoredUserInfo.sectionLockedVN.value[lockKey] ?? content.locked;

                if (isLocked) {
                  final proceed = await _confirmProceedDialog(context);
                  if (proceed != true) return;
                }

                // Preload all pages for this section into the router cache.
                await ChapterDataStore.loadAllSectionPages(
                  chapterNum: chapterNum,
                  sectionNum: sectionNum,
                );
                if (!context.mounted) return;

                // Resolve actual total pages (fallback to 1).
                int totalPages = ChapterDataStore.totalSectionPages(
                  chapterNum: chapterNum,
                  sectionNum: sectionNum,
                );
                if (totalPages < 1) totalPages = 1;

                await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => SectionContentPage(
                      chapter: chapter,
                      content: content,
                      totalPages: totalPages,
                      // ASYNC buildPage: awaits the async renderer
                      buildPage: ({
                        required Chapter chapter,
                        required ChapterContent section,
                        required int pageNumber,
                      }) async {
                        return await renderSectionPageFromCache(
                          chapter: chapter,
                          section: section,
                          pageNumber: pageNumber,
                        );
                      },
                      initialPage: 1,
                    ),
                  ),
                );
                if (!isLocked) {await StoredUserInfo.setSectionLocked(chapterNum: chapterNum, locked: false, sectionNum: sectionNum);}
              },
            ),
            if (i != widget.items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<bool?> _confirmProceedDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Proceed to locked section?'),
        content: const Text(
          "You haven't met the prerequisites for this section yet. "
          'Are you sure you would like to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // No
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), // Yes
            child: const Text('Yes'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final Chapter chapter;
  final ChapterContent item;
  final int sectionIndexFallback;
  final void Function(Chapter chapter, ChapterContent content) onOpen;

  static const Color _sectionBlue = Color(0xFF1B9CFC);
  static const Color _lockedOrange = Color(0xFFF46A1E);

  const _SectionTile({
    required this.chapter,
    required this.item,
    required this.sectionIndexFallback,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    // Use item.number if provided; otherwise fall back to list index.
    final int sectionNumber = item.number == 0 ? sectionIndexFallback : item.number;
    final int chapterNum = chapter.number;
    final String key = '$chapterNum.$sectionNumber';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpen(chapter, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row: "Section x.y" (blue) + 3-dots (no functionality yet)
              Row(
                children: [
                  Text(
                    'Section ${chapter.number}.$sectionNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _sectionBlue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: null,
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Title
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              /// Reactive body depending on lock + progress notifiers
              ValueListenableBuilder<Map<String, bool>>(
                valueListenable: StoredUserInfo.sectionLockedVN,
                builder: (_, lockedMap, _) {
                  final bool isLocked = lockedMap[key] ?? item.locked;

                  if (!isLocked) {
                    // UNLOCKED: reactive progress + description
                    return ValueListenableBuilder<Map<String, double>>(
                      valueListenable: StoredUserInfo.sectionProgressVN,
                      builder: (_, progressMap, _) {
                        final double p = (progressMap[key] ?? 0.0).clamp(0.0, 1.0);
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
                            const SizedBox(height: 10),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // LOCKED: description + orange Locked badge (reactive)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        InfoBadge(
                          leading: const Icon(Icons.lock, size: 14, color: Colors.white),
                          label: 'Locked',
                          backgroundColor: _lockedOrange,
                          labelColor: Colors.white,
                          borderColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

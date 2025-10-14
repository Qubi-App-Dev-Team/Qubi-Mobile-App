import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/pages/section_content_page.dart';
import 'package:qubi_app/pages/learn/models/section_routes.dart';
import 'package:qubi_app/pages/learn/components/gradient_progress_bar.dart';
import 'package:qubi_app/pages/learn/components/info_badge.dart';

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
                // Capture Navigator BEFORE any await to avoid using context across async gaps.
                final navigator = Navigator.of(context);

                if (content.locked) {
                  final proceed = await _confirmProceedDialog(context);
                  if (proceed != true) return;
                }

                final key = content.title.toLowerCase().replaceAll(' ', '_');
                final builder = sectionRoutes[key];
                final children = builder != null
                    ? builder(chapter, content)
                    : const [SizedBox(height: 540)];

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => SectionContentPage(
                      chapter: chapter,
                      content: content,
                      children: children,
                    ),
                  ),
                );
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
    final clampedProgress = item.progress.clamp(0.0, 1.0);
    final percentText = '${(clampedProgress * 100).round()}% progress';

    // Use item.number if provided; otherwise fall back to list index.
    final int sectionNumber = item.number;

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

              /// UNLOCKED: progress text + bar, then description (2 lines max)
              /// LOCKED:   description (2 lines), then locked badge bottom-left
              if (!item.locked) ...[
                Text(
                  percentText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GradientProgressBar(value: clampedProgress),
                const SizedBox(height: 10),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ] else ...[
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 10),
                // Orange locked badge bottom-left
                InfoBadge(
                  leading: const Icon(Icons.lock, size: 14, color: Colors.white),
                  label: 'Locked',
                  backgroundColor: _lockedOrange,
                  labelColor: Colors.white,
                  borderColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

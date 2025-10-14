import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/components/chapter_content_box.dart';
import 'package:qubi_app/pages/learn/pages/section_content_page.dart';
import 'package:qubi_app/pages/learn/models/section_routes.dart';

/// A simplified list of all section modules for a chapter.
/// - No difficulty groupings
/// - No bullets/connectors/expanders
/// - Just one module after another (like chapter tiles)
class ChapterContentSection extends StatefulWidget {
  final Chapter chapter;
  /// All content items (sections) to render as modules.
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
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final item = widget.items[i];

                // Capture Navigator BEFORE any await to avoid using context across async gaps.
                final navigator = Navigator.of(context);

                if (item.locked) {
                  final proceed = await _confirmProceedDialog(context);
                  if (proceed != true) return; // stay on this page if user says No
                }

                // Route key from title (same as before)
                final key = item.title.toLowerCase().replaceAll(' ', '_');

                final builder = sectionRoutes[key];
                final children = builder != null
                    ? builder(widget.chapter, item)
                    : const [
                        SizedBox(height: 540),
                      ];

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => SectionContentPage(
                      chapter: widget.chapter,
                      content: item,
                      children: children,
                    ),
                  ),
                );
              },
              child: ChapterContentBox(
                title: widget.items[i].title,
                description: widget.items[i].description,
                progress: widget.items[i].progress,
                locked: widget.items[i].locked,
              ),
            ),
            if (i != widget.items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  /// Section-specific confirmation dialog for locked items.
  /// Returns true if the user chooses "Yes", false otherwise.
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

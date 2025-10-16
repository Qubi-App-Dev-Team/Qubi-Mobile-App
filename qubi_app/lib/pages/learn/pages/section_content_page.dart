import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/components/section_content_header.dart';
import 'package:qubi_app/pages/learn/components/section_content_title.dart';
import 'package:qubi_app/pages/learn/components/section_page_nav_bar.dart';

/// You provide a function that builds the page body widgets for a given chapter/section/page.
/// This is where you plug in the renderer we built earlier that reads from your cache/router.
/// For example, you can pass a closure that calls:
///   renderSectionPageFromCache(chapter: chapter, section: section, pageNumber: n)
typedef SectionPageBuilder = List<Widget> Function({
  required Chapter chapter,
  required ChapterContent section,
  required int pageNumber,
});

/// Template page for a section that can flip between multiple pages
/// WITHOUT pushing new routes. It just re-renders its body in place.
class SectionContentPage extends StatefulWidget {
  final Chapter chapter;               // chapter number + title
  final ChapterContent content;        // section title/desc/progress/locked (also holds section.number)
  final int totalPages;                // total number of pages in this section
  final int initialPage;               // 1-based initial page (default 1)

  /// Builder wired to your renderer/cache lookup
  final SectionPageBuilder buildPage;

  const SectionContentPage({
    super.key,
    required this.chapter,
    required this.content,
    required this.totalPages,
    required this.buildPage,
    this.initialPage = 1,
  });

  @override
  State<SectionContentPage> createState() => _SectionContentPageState();
}

class _SectionContentPageState extends State<SectionContentPage> {
  late int _currentPage; // 1-based

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, widget.totalPages);
  }

  void _goPrev() {
    if (_currentPage <= 1) return; // no-op on first page
    setState(() => _currentPage--);
  }

  void _goNext() {
    if (_currentPage >= widget.totalPages) return; // no-op past last page
    setState(() => _currentPage++);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    // Build the page body using the injected renderer callback
    final children = widget.buildPage(
      chapter: widget.chapter,
      section: widget.content, // assumes ChapterContent has a `number`
      pageNumber: _currentPage,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SectionContentHeader(chapterNumber: widget.chapter.number),
      body: AppBackdrop(
        child: ListView(
          padding: EdgeInsets.only(top: topInset),
          children: [
            // Title bar: top (black) = chapter title, big bold = section title
            SectionContentTitle(
              chapterTitle: widget.chapter.title,
              sectionTitle: widget.content.title,
            ),

            const SizedBox(height: 16),

            // Body for the current page
            ..._padAndSpace(children),

            const SizedBox(height: 2),

            // subtle divider above the nav bar
            Container(
              height: 1,
              color: Colors.black.withValues(alpha:0.1),
            ),

            // Page nav bar (transparent, styled like your existing one)
            SectionPageNavBar(
              currentPage: _currentPage,
              totalPages: widget.totalPages,
              onPrev: _goPrev,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _padAndSpace(List<Widget> items) {
    if (items.isEmpty) return const [];
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: items[i],
      ));
      if (i != items.length - 1) out.add(const SizedBox(height: 12));
    }
    return out;
  }
}

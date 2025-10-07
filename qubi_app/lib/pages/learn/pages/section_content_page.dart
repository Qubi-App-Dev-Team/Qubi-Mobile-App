// lib/pages/learn/section_content_page.dart
import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/components/section_content_header.dart';
import 'package:qubi_app/pages/learn/components/section_content_title.dart';
import 'package:qubi_app/pages/learn/components/section_page_nav_bar.dart';

//Demo page of what an individual content page could look like
//Also to be used as a template for all content pages
class SectionContentPage extends StatelessWidget {
  final Chapter chapter;               // contains number + chapter title
  final ChapterContent content;        // contains title/desc/progress/locked
  final List<Widget> children;         // custom body for this content section

  const SectionContentPage({
    super.key,
    required this.chapter,
    required this.content,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SectionContentHeader(chapterNumber: chapter.number),
      body: AppBackdrop(
        child: ListView(
          padding: EdgeInsets.only(top: topInset),
          children: [
            // Title bar: top (black) = chapter title, big bold = content title
            SectionContentTitle(
              chapterTitle: chapter.title,
              sectionTitle: content.title,
            ),

            const SizedBox(height: 16),
            ..._padAndSpace(children),
            const SizedBox(height: 2),
            Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.1), // subtle dark divider
            ),
            SectionPageNavBar(
              currentPage: 1,
              totalPages: 3,
            )
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
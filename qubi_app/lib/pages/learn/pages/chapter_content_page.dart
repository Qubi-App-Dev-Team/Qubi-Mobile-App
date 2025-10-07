import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/components/chapter_content_header.dart';
import 'package:qubi_app/pages/learn/components/chapter_content_title.dart';
import 'package:qubi_app/pages/learn/components/chapter_content_container.dart';

/// Template page for displaying the content of any given chapter.
/// Expects a Chapter model; fills body with your future content widgets.

class ChapterContentPage extends StatelessWidget {
  final Chapter chapter;

  const ChapterContentPage({super.key, required this.chapter});
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double topInset = media.padding.top + kToolbarHeight; 
    return Scaffold(
      extendBodyBehindAppBar: true, // let the background flow under the header
      appBar: const ChapterContentHeader(),
      body: AppBackdrop(
        child: ListView(
          padding: EdgeInsets.only(top: topInset),
          children: [
            ChapterContentTitle(chapter: chapter),
            const SizedBox(height: 12),
            const ChapterContentContainer(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/components/chapter_content_section.dart';
import 'package:qubi_app/pages/learn/bloc/chapter_data_store.dart';

/// Container component for the individual sections within a chapter.
/// Dynamically loads sections from the data store using the chapter number.
class ChapterContentContainer extends StatelessWidget {
  final Chapter chapter;

  const ChapterContentContainer({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChapterContent>>(
      future: ChapterDataStore.loadAllSections(chapterNum: chapter.number),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load sections.\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        final items = snapshot.data ?? const <ChapterContent>[];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No sections available yet.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children: [
            ChapterContentSection(
              chapter: chapter,
              items: items,
            ),
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }
}

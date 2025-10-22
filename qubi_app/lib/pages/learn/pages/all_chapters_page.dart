import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:qubi_app/pages/learn/components/top_bar.dart';
import 'package:qubi_app/pages/learn/components/all_chapters_container.dart';
import 'package:qubi_app/pages/learn/components/chapter_info.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/bloc/chapter_data_store.dart';

/// Page with information about all chapters
class AllChaptersPage extends StatelessWidget {
  const AllChaptersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Strawford',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Strawford'),
          bodyMedium: TextStyle(fontFamily: 'Strawford'),
        ),
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const TopBar(),
        body: AppBackdrop(
          child: FutureBuilder<List<Chapter>>(
            future: ChapterDataStore.loadAllChapters(), // ← your loader
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load chapters.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              final chapters = snapshot.data ?? const <Chapter>[];
              if (chapters.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No chapters available yet.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              // Build the list of ChapterInfo widgets (only pass the Chapter object)
              final children = chapters
                  .map((c) => ChapterInfo(chapter: c))
                  .toList(growable: false);

              return Center(
                child: AllChaptersContainer(children: children),
              );
            },
          ),
        ),
      ),
    );
  }
}

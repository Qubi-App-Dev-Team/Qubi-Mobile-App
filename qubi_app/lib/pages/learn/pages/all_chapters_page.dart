import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_backdrop.dart';
import 'package:qubi_app/pages/learn/components/top_bar.dart';
import 'package:qubi_app/pages/learn/components/all_chapters_container.dart';
import 'package:qubi_app/pages/learn/components/chapter_info.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';

//Page with information about all chapters
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
        body: const AppBackdrop(
          child: Center(
            child: AllChaptersContainer(
          // Replace these placeholders with your future ChapterInfo widgets
              children: [
                 ChapterInfo(
                  chapter: Chapter(number: 1, title: "Discover the Laws of Quantum"),
                  progress: 0.26,
                  difficulty: "beginner",
                  skinsUnlocked: 0
                 ),
                 ChapterInfo(
                  chapter: Chapter(number: 2, title: "Learn the first Quantum Algorithms"),
                  progress: 0.0,
                  difficulty: "intermediate",
                  skinsUnlocked: 0,
                  locked: true
                 ),
                 ChapterInfo(
                  chapter: Chapter(number: 3, title: "Bit Commitment"),
                  progress: 0.05,
                  difficulty: "Advanced",
                  skinsUnlocked: 0,
                  locked: true
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
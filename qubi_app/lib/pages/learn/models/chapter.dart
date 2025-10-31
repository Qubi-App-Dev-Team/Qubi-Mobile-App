import 'package:flutter/foundation.dart';

//Class for holding data to be passed to ChapterContent page
//Will later need to be updated to grab chapter content from a database

@immutable
class Chapter {
  final int number;
  final String title;
  final double progress;
  final String difficulty;
  final bool locked; 
  final int skinsUnlocked;

  const Chapter({
    required this.number,
    required this.title,
    required this.progress,
    required this.difficulty,
    required this.locked,
    required this.skinsUnlocked
  });
}
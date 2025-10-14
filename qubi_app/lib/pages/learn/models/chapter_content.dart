import 'package:flutter/foundation.dart';

//Model for passing information about the content of a chapter
//Will be important when including backend logic
@immutable
class ChapterContent{
  final String title;
  final String description;
  final double progress; // 0..1
  final bool locked;

  const ChapterContent({
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.locked = true,
  });
}

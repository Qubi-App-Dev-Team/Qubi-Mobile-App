import 'package:flutter/foundation.dart';

//Model for passing information about the content of a chapter
//Will be important when including backend logic
@immutable
class ChapterContent{
  final String title;
  final String description;
  final bool locked;
  final int number;

  const ChapterContent({
    required this.title,
    required this.description,
    required this.locked,
    required this.number,
  });
}

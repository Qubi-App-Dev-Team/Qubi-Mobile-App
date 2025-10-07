import 'package:flutter/widgets.dart';
import 'package:qubi_app/pages/learn/components/measurement_section_body.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';

/// A typedef for how each section will build its widget list.
typedef SectionBuilder = List<Widget> Function(Chapter chapter, ChapterContent content);

/// Fixed map (hashmap) of section identifiers -> body builders.
/// You can add new entries here for each unique section.
final Map<String, SectionBuilder> sectionRoutes = {
  'measurement': (chapter, content) => const [MeasurementSectionBody()],
};

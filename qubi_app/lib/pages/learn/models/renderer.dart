import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';

// Shared UI bits
import 'package:qubi_app/pages/learn/styles/content_styles.dart';
import 'package:qubi_app/pages/learn/components/section_page_header.dart';
import 'package:qubi_app/pages/learn/components/section_page_paragraph.dart';
import 'package:qubi_app/pages/learn/components/section_page_network_image.dart';

// Your router spec cache: Map<String, List<Map<String, dynamic>>>
import 'package:qubi_app/pages/learn/models/section_routes.dart';

/// "chapter.section.page" (e.g., "1.2.3")
String sectionPageKey({
  required int chapterNumber,
  required int sectionNumber,
  required int pageNumber,
}) =>
    '$chapterNumber.$sectionNumber.$pageNumber';

/// Converts cached specs -> Widgets for a given chapter/section/page.
/// If no specs are found, returns [SizedBox(height: 540)].
List<Widget> renderSectionPageFromCache({
  required Chapter chapter,
  required ChapterContent section,
  required int pageNumber,
}) {
  final key = sectionPageKey(
    chapterNumber: chapter.number,
    sectionNumber: section.number,
    pageNumber: pageNumber,
  );

  final specs = sectionRoutes[key];
  if (specs == null || specs.isEmpty) {
    return const [SizedBox(height: 540)];
  }

  final widgets = <Widget>[];

  for (final block in specs) {
    if (block.isEmpty) continue;
    final type = block.keys.first;
    final value = block[type];

    switch (type) {
      case 'header': {
        final text = (value ?? '').toString().trim();
        if (text.isEmpty) break;
        widgets
          ..add(SectionPageHeader(text: text))
          ..add(const SizedBox(height: 24));
        break;
      }

      case 'paragraph': {
        final text = (value ?? '').toString().trim();
        if (text.isEmpty) break;
        widgets
          ..add(SectionPageParagraph(text: text))
          ..add(const SizedBox(height: 24));
        break;
      }

      case 'image': {
        final url = (value ?? '').toString().trim();
        if (url.isEmpty) break;
        widgets
          ..add(SectionPageNetworkImage(url: url))
          ..add(const SizedBox(height: 24));
        break;
      }

      case 'prompt': {
        // NEW: prompt value is a List<Map<String,dynamic>> laid out vertically
        if (value is! List) {
          // Guard: wrong shape; show a friendly fallback
          widgets
            ..add(_unsupported('prompt expects a List<Map>'))
            ..add(const SizedBox(height: 16));
          break;
        }
        final promptChildren = _buildPromptChildren(value);
        widgets
          ..add(
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ContentStyles.cardBorder),
                boxShadow: const [ContentStyles.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: promptChildren,
              ),
            ),
          )
          ..add(const SizedBox(height: 24));
        break;
      }

      default: {
        widgets
          ..add(_unsupported('Unsupported block: $type'))
          ..add(const SizedBox(height: 16));
      }
    }
  }

  widgets.add(const SizedBox(height: 40));
  return widgets;
}

/// Builds the vertical contents INSIDE a prompt card from a List<Map>.
/// Supported inner blocks: header, paragraph, image, options
List<Widget> _buildPromptChildren(List<dynamic> innerSpecs) {
  final children = <Widget>[];

  for (final raw in innerSpecs) {
    if (raw is! Map || raw.isEmpty) continue;
    final type = raw.keys.first;
    final value = raw[type];

    switch (type) {
      case 'header': {
        final text = (value ?? '').toString().trim();
        if (text.isEmpty) break;
        children
          ..add(SectionPageHeader(text: text))
          ..add(const SizedBox(height: 18));
        break;
      }

      case 'paragraph': {
        final text = (value ?? '').toString().trim();
        if (text.isEmpty) break;
        children
          ..add(SectionPageParagraph(text: text))
          ..add(const SizedBox(height: 18));
        break;
      }

      case 'image': {
        final url = (value ?? '').toString().trim();
        if (url.isEmpty) break;
        children
          ..add(SectionPageNetworkImage(url: url))
          ..add(const SizedBox(height: 18));
        break;
      }

      case 'options': {
        // value must be List<String>
        final List<String> options = (value as List?)
                ?.whereType<String>()
                .toList(growable: false) ??
            const <String>[];

        for (int i = 0; i < options.length; i++) {
          final label = options[i];
          children.add(
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {}, // hook business logic later
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  side: const BorderSide(color: ContentStyles.cardBorder),
                  textStyle: ContentStyles.body,
                ),
                child: RichText(
                  text: TextSpan(
                    style: ContentStyles.body,
                    children: [TextSpan(text: label)],
                  ),
                ),
              ),
            ),
          );
          if (i != options.length - 1) {
            children.add(const SizedBox(height: 16));
          }
        }
        if (options.isNotEmpty) {
          // Space after the options group to separate from any following block
          children.add(const SizedBox(height: 2));
        }
        break;
      }

      default: {
        children
          ..add(_unsupported('Unsupported prompt block: $type'))
          ..add(const SizedBox(height: 12));
      }
    }
  }

  return children;
}

Widget _unsupported(String message) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: ContentStyles.backgroundGray.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(message, style: ContentStyles.body),
  );
}

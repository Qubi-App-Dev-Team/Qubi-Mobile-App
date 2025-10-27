import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';

// Shared UI bits
import 'package:qubi_app/pages/learn/styles/content_styles.dart';
import 'package:qubi_app/pages/learn/components/section_page_header.dart';
import 'package:qubi_app/pages/learn/components/section_page_paragraph.dart';
import 'package:qubi_app/pages/learn/components/section_page_network_image.dart';
import 'package:qubi_app/pages/learn/components/prompt_option_button.dart';
// Your router spec cache: Map<String, List<Map<String, dynamic>>>
import 'package:qubi_app/pages/learn/models/section_routes.dart';
import 'package:flutter/foundation.dart';

/// "chapter.section.page" (e.g., "1.2.3")
String sectionPageKey({
  required int chapterNumber,
  required int sectionNumber,
  required int pageNumber,
}) =>
    '$chapterNumber.$sectionNumber.$pageNumber';

/// Converts cached specs -> Widgets for a given chapter/section/page.
/// If no specs are found, returns [SizedBox(height: 540)].
/// Tolerant of unknown/malformed blocks: skips them without failing the whole page.
Future<List<Widget>> renderSectionPageFromCache({
  required Chapter chapter,
  required ChapterContent section,
  required int pageNumber,
}) async {
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
    try {
      if (block.isEmpty) continue;

      // Normalize type & value keys
      final String type = _readType(block);
      final dynamic value = _readValue(block);

      switch (type) {
        case 'header': {
          final text = (value ?? '').toString().trim();
          if (text.isEmpty) break;
          widgets
            ..add(SectionPageHeader(text: text))
            ..add(const SizedBox(height: 8));
          break;
        }

        case 'paragraph': {
          final text = (value ?? '').toString().trim();
          if (text.isEmpty) break;
          widgets
            ..add(SectionPageParagraph(text: text))
            ..add(const SizedBox(height: 8));
          break;
        }

        case 'image': {
          final url = (value ?? '').toString().trim();
          if (url.isEmpty) break;
          widgets
            ..add(SectionPageNetworkImage(url: url))
            ..add(const SizedBox(height: 8));
          break;
        }

        case 'list': {
          // top-level bulleted list
          final items = _asStringList(value);
          if (items.isEmpty) break;
          widgets
            ..add(_buildBulletedList(items))
            ..add(const SizedBox(height: 8));
          break;
        }

        case 'prompt': {
          // PROMPT expects a List of inner maps, each with exactly one key/value.
          if (value is! List) {
            // Skip silently; log in debug
            if (kDebugMode) {
              debugPrint('[renderer] prompt expects a List<Map>, got: ${value.runtimeType}');
            }
            break;
          }

          final promptChildren = _buildPromptChildren(
            value.cast<dynamic>(),
          );

          if (promptChildren.isEmpty) break;

          widgets
            ..add(
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
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
            ..add(const SizedBox(height: 8));
          break;
        }

        default:
          // Unknown/unsupported block (e.g., "answer"): skip silently.
          if (kDebugMode) {
            debugPrint('[renderer] Skipping unsupported block type: $type');
          }
          continue;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[renderer] Error rendering block $block: $e');
        debugPrint('$st');
      }
      // Add a very small, unobtrusive warning spacer (or omit entirely)
      widgets.add(const SizedBox(height: 8));
    }
  }

  widgets.add(const SizedBox(height: 15));
  return widgets;
}

/// Builds the vertical contents INSIDE a prompt card from a List<Map>.
/// Supported inner blocks: header, paragraph, image, options
List<Widget> _buildPromptChildren(List<dynamic> innerSpecs) {
  final children = <Widget>[];

  for (final raw in innerSpecs) {
    try {
      if (raw is! Map || raw.isEmpty) {
        debugPrint('Inner type of prompt was not a map: ${raw.runtimeType}');
        continue;
      }
      // For prompt inner blocks, each entry is a single-key map, e.g. { "header": "Text" }
      final String type = raw.keys.first.toString();
      final dynamic value = raw[type];

      switch (type.toLowerCase()) {
        case 'header': {
          final text = (value ?? '').toString().trim();
          if (text.isEmpty) break;
          children
            ..add(SectionPageHeader(text: text))
            ..add(const SizedBox(height: 10));
          break;
        }

        case 'paragraph': {
          final text = (value ?? '').toString().trim();
          if (text.isEmpty) break;
          children
            ..add(SectionPageParagraph(text: text))
            ..add(const SizedBox(height: 10));
          break;
        }

        case 'image': {
          final url = (value ?? '').toString().trim();
          if (url.isEmpty) break;
          children
            ..add(SectionPageNetworkImage(url: url))
            ..add(const SizedBox(height: 10));
          break;
        }

        case 'list': {
          // prompt inner bulleted list
          final items = _asStringList(value);
          if (items.isEmpty) break;
          children
            ..add(_buildBulletedList(items))
            ..add(const SizedBox(height: 10));
          break;
        }

        case 'options': {
          final List<String> options = _asStringList(value);
          if (options.isEmpty) break;

          for (int i = 0; i < options.length; i++) {
            children.add(
              PromptOptionButton(
                label: options[i],
                // alternate background: even = white, odd = light gray
                isAlternate: i.isOdd,
              ),
            );
            if (i != options.length - 1) {
              children.add(const SizedBox(height: 15));
            }
          }

          if (options.isNotEmpty) {
            children.add(const SizedBox(height: 15));
          }
          break;
        }


        default:
          // Unknown inner type (e.g., "answer"): skip silently
          if (kDebugMode) {
            debugPrint('[renderer] Skipping unsupported prompt block: $type');
          }
          continue;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[renderer] Error rendering prompt child $raw: $e');
        debugPrint('$st');
      }
      children.add(const SizedBox(height: 6));
    }
  }

  return children;
}

/// Normalizes "type" / "component" and lowercases it.
/// Returns empty string if not present/parsable.
String _readType(Map<String, dynamic> block) {
  final dynamic raw = block['type'] ?? block['component'];
  final type = (raw ?? '').toString().trim().toLowerCase();
  return type;
}

/// Normalizes "content" / "value" for top-level blocks.
dynamic _readValue(Map<String, dynamic> block) {
  return block.containsKey('content') ? block['content'] : block['value'];
}

/// Safely converts a Firestore value to a List`<`String`>`.
List<String> _asStringList(dynamic value) {
  if (value == null) return const <String>[];

  if (value is List) {
    return value
        .map((e) => e?.toString().trim())
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }

  return const <String>[];
}

/// Renders a vertical bulleted list with small circular bullets
/// using ContentStyles.body for text.
Widget _buildBulletedList(List<String> items) {
  const bulletSize  = 6.0;   // small filled circle
  const bulletGap   = 10.0;  // space between bullet and text
  const rowGap      = 10.0;  // vertical space between items
  const bulletColor = Colors.black87;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (int i = 0; i < items.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet dot (nudged to align with first text line)
            Container(
              width: bulletSize,
              height: bulletSize,
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: bulletGap),

            // Use the SAME render path as paragraphs: RichText + TextSpan(ContentStyles.body)
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: ContentStyles.body, // exact same style as SectionPageParagraph
                  children: [TextSpan(text: items[i])],
                ),
                // (Optional) match any paragraph textHeightBehavior if you use one:
                // textHeightBehavior: const TextHeightBehavior(
                //   applyHeightToFirstAscent: false,
                //   applyHeightToLastDescent: false,
                // ),
                // Soft-wrap by default; no explicit maxLines
              ),
            ),
          ],
        ),
        if (i != items.length - 1) const SizedBox(height: rowGap),
      ],
    ],
  );
}





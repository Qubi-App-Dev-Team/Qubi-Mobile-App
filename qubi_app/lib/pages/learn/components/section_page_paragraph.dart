import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/styles/content_styles.dart';

class SectionPageParagraph extends StatelessWidget {
  final String text;

  const SectionPageParagraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: ContentStyles.body,
        children: [TextSpan(text: text)],
      ),
    );
  }
}

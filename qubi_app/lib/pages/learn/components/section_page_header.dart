import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/styles/content_styles.dart';

class SectionPageHeader extends StatelessWidget {
  final String text;

  const SectionPageHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: ContentStyles.header,
        children: [TextSpan(text: text)],
      ),
    );
  }
}

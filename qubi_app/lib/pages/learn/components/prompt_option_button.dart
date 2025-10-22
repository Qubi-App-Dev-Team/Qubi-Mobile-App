import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/styles/content_styles.dart';

/// A stylized option button used inside Prompt components.
/// - Alternates between white and light gray backgrounds
/// - Adjusts its vertical padding based on the number of text lines
/// - Uses ContentStyles.buttonText for consistent typography
class PromptOptionButton extends StatelessWidget {
  final String label;
  final bool isAlternate;
  final VoidCallback? onPressed;

  const PromptOptionButton({
    super.key,
    required this.label,
    this.isAlternate = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure how many lines the label wraps to
        final textStyle = ContentStyles.buttonText;
        const horizontalPad = 20.0;
        final availableWidth =
            (constraints.maxWidth - (horizontalPad * 2)).clamp(0.0, double.infinity);

        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          maxLines: 10,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: availableWidth);

        final perLineHeight =
            (textStyle.fontSize ?? 16) * (textStyle.height ?? 1.5);
        final lineCount = (tp.size.height / perLineHeight).ceil().clamp(1, 10);

        // Increase padding slightly for multi-line text
        const baseVerticalPad = 12.0;
        const extraPerLine = 4.0;
        final verticalPad = baseVerticalPad + (lineCount - 1) * extraPerLine;

        final backgroundColor =
            isAlternate ? const Color(0xFFE6EEF8) : Colors.white;
        final borderSide = isAlternate
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFD6DEE9));

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: const StadiumBorder(),
              side: borderSide,
              padding: EdgeInsets.symmetric(
                vertical: verticalPad,
                horizontal: horizontalPad,
              ),
            ),
            child: Text(
              label,
              style: textStyle,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        );
      },
    );
  }
}

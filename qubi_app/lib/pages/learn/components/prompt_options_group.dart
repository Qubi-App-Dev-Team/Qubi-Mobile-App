import 'package:flutter/material.dart';
import 'package:qubi_app/pages/learn/styles/content_styles.dart';
import 'package:qubi_app/pages/learn/components/prompt_option_button.dart';

/// Multiple-choice group with required answer + explanation.
/// - User selects an option, taps "Check answer"
/// - Shows correctness pill and always shows the explanation after checking
/// - Does not persist results
class PromptOptionsGroup extends StatefulWidget {
  final List<String> options;
  final int answerIndex;         // REQUIRED, non-null
  final String explanation;      // REQUIRED, non-null

  /// Optional: alternate (zebra) background for options, default true
  final bool alternateColors;

  /// Optional callback if you want to track user results (analytics, etc.)
  final void Function(bool isCorrect)? onChecked;

  /// Optional: allow trying again after checking. Default false (locks after check).
  final bool allowRetry;

  const PromptOptionsGroup({
    super.key,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    this.alternateColors = true,
    this.onChecked,
    this.allowRetry = false,
  }) : assert(options.length > 0, 'options must not be empty'),
       assert(
         answerIndex >= 0 && answerIndex < options.length,
         'answerIndex must be a valid index into options',
       );

  @override
  State<PromptOptionsGroup> createState() => _PromptOptionsGroupState();
}

class _PromptOptionsGroupState extends State<PromptOptionsGroup> {
  int? _selected;        // index the user tapped
  bool _checked = false; // whether "Check answer" has been pressed

  bool get _isCorrect =>
      _checked && _selected != null && _selected == widget.answerIndex;

  void _select(int index) {
    if (_checked && !widget.allowRetry) return; // lock after check (unless retry enabled)
    setState(() => _selected = index);
  }

  void _check() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option first.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() => _checked = true);
    widget.onChecked?.call(_isCorrect);
  }

  void _reset() {
    setState(() {
      _selected = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Options list =====
        for (int i = 0; i < options.length; i++) ...[
          _OptionLine(
            label: options[i],
            index: i,
            isAlternate: widget.alternateColors ? i.isOdd : false,
            isSelected: _selected == i,
            isCorrect: _checked && i == widget.answerIndex,
            isIncorrectSelected: _checked && _selected == i && i != widget.answerIndex,
            onTap: () => _select(i),
          ),
          if (i != options.length - 1) const SizedBox(height: 12),
        ],

        const SizedBox(height: 16),

        // ===== Action row =====
        Row(
          children: [
            ElevatedButton(
              onPressed: _checked && !widget.allowRetry ? null : _check,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                textStyle: ContentStyles.buttonText,
              ),
              child: Text(_checked && widget.allowRetry ? 'Check again' : 'Check answer'),
            ),
            const SizedBox(width: 12),
            if (_checked && widget.allowRetry)
              TextButton(
                onPressed: _reset,
                child: const Text('Retry'),
              ),
            const Spacer(),
            if (_checked)
              _ResultChip(isCorrect: _isCorrect),
          ],
        ),

        // ===== Explanation (always shown after checking, required non-empty) =====
        if (_checked) ...[
          const SizedBox(height: 16),
          _ExplanationCard(text: widget.explanation),
        ],
      ],
    );
  }
}

/// One option row with visual feedback around the PromptOptionButton.
class _OptionLine extends StatelessWidget {
  final String label;
  final int index;
  final bool isAlternate;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrectSelected;
  final VoidCallback onTap;

  const _OptionLine({
    required this.label,
    required this.index,
    required this.isAlternate,
    required this.isSelected,
    required this.isCorrect,
    required this.isIncorrectSelected,
    required this.onTap,
  });

  Color? get _borderColor {
    if (isCorrect) return const Color(0xFF23D5AF); // green
    if (isIncorrectSelected) return const Color(0xFFE74C3C); // red
    if (isSelected) return const Color(0xFF1B9CFC); // blue
    return null; // no extra border
  }

  IconData? get _trailIcon {
    if (isCorrect) return Icons.check_circle;
    if (isIncorrectSelected) return Icons.cancel;
    if (isSelected) return Icons.radio_button_checked; // subtle cue pre-check
    return null;
  }

  Color get _trailColor {
    if (isCorrect) return const Color(0xFF23D5AF);
    if (isIncorrectSelected) return const Color(0xFFE74C3C);
    if (isSelected) return const Color(0xFF1B9CFC);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _borderColor;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // Outer border wrapper
        Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: borderColor != null
                  ? BorderSide(color: borderColor, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: PromptOptionButton(
            label: label,
            isAlternate: isAlternate,
            onPressed: onTap,
          ),
        ),
        if (_trailIcon != null)
          Positioned(
            right: 12,
            child: Icon(_trailIcon, color: _trailColor, size: 20),
          ),
      ],
    );
  }
}

/// Small result pill that says Correct / Not quite after checking
class _ResultChip extends StatelessWidget {
  final bool isCorrect;
  const _ResultChip({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final bg = isCorrect ? const Color(0xFF23D5AF) : const Color(0xFFE74C3C);
    final label = isCorrect ? 'Correct' : 'Not quite';

    final textColor = _darken(bg, 0.05); // slightly darker than bg

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg),
      ),
      child: Text(
        label,
        style: ContentStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Utility: darken a color by [amount] (0..1) using HSL
Color _darken(Color color, [double amount = 0.1]) {
  final hsl = HSLColor.fromColor(color);
  final l = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

/// Explanation card styled like your other content cards
class _ExplanationCard extends StatelessWidget {
  final String text;
  const _ExplanationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ContentStyles.cardBorder),
        boxShadow: const [ContentStyles.cardShadow],
      ),
      child: RichText(
        text: TextSpan(
          style: ContentStyles.body,
          children: [TextSpan(text: text)],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

//Class for the small badges that appear on screen (locked, skins, etc.)
class InfoBadge extends StatelessWidget {
  final Widget leading;
  final String label;

  /// Background color of the pill (e.g., #F46A1E for locked, #E6EEF8 for others)
  final Color backgroundColor;

  /// Optional label color (defaults to a readable dark text)
  final Color? labelColor;

  /// Optional border color (defaults to a subtle transparent black)
  final Color? borderColor;

  /// Padding inside the pill
  final EdgeInsetsGeometry padding;

  const InfoBadge({
    super.key,
    required this.leading,
    required this.label,
    required this.backgroundColor,
    this.labelColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final textColor = labelColor ?? Colors.black87;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor ?? Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

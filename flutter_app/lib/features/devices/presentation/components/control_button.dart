import 'package:flutter/material.dart';
import 'package:qubi/core/theme/app_theme.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final btn = Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: expanded ? null : (width ?? 56),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          backgroundColor: AppColors.saltWhite,
          minimumSize: const Size(0, 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, height: 1.1),
        ),
      ),
    );

    if (expanded) return Expanded(child: btn);
    return btn;
  }
}

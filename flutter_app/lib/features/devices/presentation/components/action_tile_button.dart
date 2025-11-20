import 'package:flutter/material.dart';

class ActionTileButton extends StatelessWidget {
  const ActionTileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  this.width = 72,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final bg = Colors.white; // solid white like gate buttons
  final borderColor = isDark
    ? Colors.white.withOpacity(0.25)
    : Colors.black.withOpacity(0.12);

    return SizedBox(
      width: width,
      height: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

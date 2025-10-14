import 'package:flutter/material.dart';

/// Progrsss bar, self explanatory, Left segment = gradient (completed), right segment = solid gray (incomplete).
class GradientProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final filled = total * v;
        final unfilled = total - filled;

        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Row(
              children: [
                // Completed: gradient segment (left)
                if (filled > 0)
                  SizedBox(
                    width: filled,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF23D5AF),
                            Color(0xFF1A91FC),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Incomplete: solid gray segment (right)
                if (unfilled > 0)
                  SizedBox(
                    width: unfilled,
                    child: Container(
                      color: const Color(0xFFE5E7EB), // neutral gray
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

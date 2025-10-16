import 'package:flutter/material.dart';

class QubiCard extends StatelessWidget {
  final String title;
  final Color qubiColor;

  const QubiCard({super.key, required this.title, required this.qubiColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // later add glassmorphism
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: qubiColor,
                        width: 4.5, // thickness of the donut ring
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.info_outline, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          // gates in two rows
          Column(
            children: [
              Row(
                children: const [
                  Expanded(child: QubiGateButton(label: "X", topLeft: true)),
                  Expanded(child: QubiGateButton(label: "Y")),
                  Expanded(child: QubiGateButton(label: "Z")),
                  Expanded(child: QubiGateButton(label: "T")),
                  Expanded(child: QubiGateButton(label: "T*")),
                  Expanded(child: QubiGateButton(label: "H", topRight: true)),
                ],
              ),
              Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: QubiGateButton(label: "CNOT", bottomLeft: true),
                  ),
                  Expanded(flex: 3, child: QubiGateButton(label: "Measure")),
                  Expanded(
                    flex: 1,
                    child: QubiGateButton(label: "⌄", bottomRight: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QubiGateButton extends StatelessWidget {
  final String label;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const QubiGateButton({
    super.key,
    required this.label,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // center the label
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: .05), // small gap between buttons
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFC7DDF0), width: 1),
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? const Radius.circular(8) : Radius.zero,
          topRight: topRight ? const Radius.circular(8) : Radius.zero,
          bottomLeft: bottomLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: bottomRight ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

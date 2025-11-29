import 'package:flutter/material.dart';

class QubiCard extends StatelessWidget {
  final String title;
  final Color qubiColor;
  final int qubitIndex;
  final Function(String gateType, int qubitIndex) onGatePressed;
  final Function(int qubitIndex) onDeletePressed;

  const QubiCard({super.key, required this.title, required this.qubiColor, required this.qubitIndex, required this.onGatePressed, required this.onDeletePressed});

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
                children: [
                  Expanded(child: QubiGateButton(label: "X",  topLeft: true,  onPressed: () => onGatePressed("x", qubitIndex))),
                  Expanded(child: QubiGateButton(label: "Y",  onPressed: () => onGatePressed("y", qubitIndex))),
                  Expanded(child: QubiGateButton(label: "Z",  onPressed: () => onGatePressed("z", qubitIndex))),
                  Expanded(child: QubiGateButton(label: "T",  onPressed: () => onGatePressed("t", qubitIndex))),
                  Expanded(child: QubiGateButton(label: "T*", onPressed: () => onGatePressed("t*", qubitIndex))),
                  Expanded(child: QubiGateButton(label: "H",  topRight: true, onPressed: () => onGatePressed("h", qubitIndex))),
                ],
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: QubiGateButton(label: "CNOT",  bottomLeft: true, onPressed: () => onGatePressed("cx", qubitIndex))),
                  Expanded(flex: 3, child: QubiGateButton(label: "Measure", onPressed: () { print("Needs Something"); })),
                  Expanded(flex: 1, child: QubiGateButton(label: "⌄", bottomRight: true, onPressed: () => onDeletePressed(qubitIndex))),
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
  final VoidCallback onPressed;

  const QubiGateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: topLeft ? const Radius.circular(8) : Radius.zero,
      topRight: topRight ? const Radius.circular(8) : Radius.zero,
      bottomLeft: bottomLeft ? const Radius.circular(8) : Radius.zero,
      bottomRight: bottomRight ? const Radius.circular(8) : Radius.zero,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: .05),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: Color(0xFFC7DDF0), width: 1),
        ),
        clipBehavior: Clip.antiAlias, // so ripple clips to rounded corners
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          splashColor: Colors.teal.withValues(alpha: 0.2),
          highlightColor: Colors.teal.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

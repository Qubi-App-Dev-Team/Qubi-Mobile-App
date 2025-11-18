import 'package:flutter/material.dart';

class Gate {
  final String type;        // gate name
  final List<int> qubits;   // qubits
  final int position;       // index

  Gate({
    required this.type,
    required this.qubits,
    required this.position,
  });

  factory Gate.fromJson(Map<String, dynamic> json, int position) {
    return Gate(
      type: json['name'],                     // JSON uses "name"
      qubits: List<int>.from(json['qubit']),  // qubit list
      position: position,                     // assign based on index
    );
  }
}
class CircuitView extends StatelessWidget {
  final List<Gate> gates;
  final double gridSpacing;
  final Color color1;
  final Color color2;

  const CircuitView({
    super.key,
    required this.gates,
    this.color1 = const Color(0xFF66E3C4),
    this.color2 = const Color(0xFF9D6CFF),
    this.gridSpacing = 80,
  });

  int get numPositions => gates.length + 1;

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.only(top: 10),
    child: SizedBox(
      width: numPositions * gridSpacing,
      height: 200,
      child: Stack(
        children: [
          for (int q = 0; q < 2; q++) ...[
            Positioned(
              top: 41.0 + (q * 80),
              left: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: q == 0 ? color1 : color2,
                    width: 4.5, // thickness of the donut ring
                  ),
                ),
              ),
            ),

            // horizontal grid lines
            Positioned(
              top: 50.0 + (q * 80),
              left: 40,
              right: 0,
              child: Container(height: 2, color: Colors.black),
            ),
          ],

          // placing gates
          for (final gate in gates)
            // multi-qubit gates
            if (gate.type == 'cx' || gate.type == 'cz') ...[
              Positioned( // positions gate
                left: (gate.position + 1) * gridSpacing - 30,
                top: 50.0 + (gate.qubits[0] * 80) - 30,
                child: Image.asset(
                  'assets/gates/${gate.type[1]}.png',
                  width: 60,
                  height: 60,
                ),
              ),
              Positioned( // draw control dot
                left: (gate.position + 1) * gridSpacing - 10,
                top: 50.0 + (gate.qubits[1] * 80) - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // drawing connecting line
              if (gate.qubits[1] == 0) // top to bottom
                Positioned(
                  left: (gate.position + 1) * gridSpacing - 2,
                  top: 50.0 + (gate.qubits[1] * 80),
                  child: Container(
                    width: 4,
                    height: 55,
                    color: Colors.blue,
                  ),
                )
              else // bottom to top
                Positioned(
                  left: (gate.position + 1) * gridSpacing - 2,
                  bottom: (gate.qubits[1] * 80) - 15,
                  child: Container(
                    width: 4,
                    height: 58,
                    color: Colors.blue,
                  ),
                ),

            ] else // single qubit gates
              Positioned(
                left: (gate.position + 1) * gridSpacing - 30,
                top: 20.0 + (gate.qubits[0] * 80),
                child: Image.asset(
                  'assets/gates/${gate.type}.png',
                  width: 60,
                  height: 60,
                ),
              )
          ],
        ),
      )
    );
  }
}

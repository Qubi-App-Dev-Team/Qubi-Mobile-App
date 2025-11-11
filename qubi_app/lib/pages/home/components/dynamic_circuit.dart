import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Gate {
  final int qubit; // line 1 or 2
  final int position; // grid position
  final String type; // gate type H CNOT
  final int? target; // for CNOT

  Gate({required this.qubit, required this.position, required this.type, this.target});

  factory Gate.fromJson(Map<String, dynamic> json) {
    return Gate(
      qubit: json['qubit'],
      position: json['position'],
      type: json['type'],
      target: json['target'],
    );
  }
}

class CircuitView extends StatelessWidget {
  final List<Gate> gates;
  final int numPositions;
  final double gridSpacing;

  const CircuitView({
    super.key,
    required this.gates,
    this.numPositions = 10,
    this.gridSpacing = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: numPositions * gridSpacing,
      child: Stack(
        children: [
          // Draw 2 horizontal lines for 2 qubits
          for (int q = 0; q < 2; q++)
            Positioned(
              top: 50.0 + (q * 80),
              left: 0,
              right: 0,
              child: Container(height: 2, color: Colors.black),
            ),

          // Draw vertical grid markers
          for (int i = 0; i <= numPositions; i++)
            Positioned(
              left: i * gridSpacing,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: Colors.grey.shade300),
            ),

          // Place gates
          for (final gate in gates)
            Positioned(
              left: gate.position * gridSpacing - 30,
              top: 50.0 + (gate.qubit * 80) - 30,
              child: Image.asset(
                'assets/gates/${gate.type}.png',
                width: 60,
                height: 60,
              ),
            ),
        ],
      ),
    );
  }
}


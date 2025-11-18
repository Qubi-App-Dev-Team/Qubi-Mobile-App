import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_colors.dart';

class Gate {
  final int qubit; // control or single-qubit line
  final int position; // column
  final String type; // "X", "H", "CNOT"
  final int? target; // only for CNOT

  Gate({
    required this.qubit,
    required this.position,
    required this.type,
    this.target,
  });

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
    this.numPositions = 12,
    this.gridSpacing = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: numPositions * gridSpacing,
      child: Stack(
        children: [
          // -------------------------------------
          // Draw 2 qubit wires
          // -------------------------------------
          for (int q = 0; q < 2; q++)
            Positioned(
              top: 50 + (q * 80),
              left: 0,
              right: 0,
              child: Container(height: 2, color: Colors.black),
            ),

          // -------------------------------------
          // Draw vertical grid markers
          // -------------------------------------
          for (int i = 0; i <= numPositions; i++)
            Positioned(
              left: i * gridSpacing,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: Colors.grey.shade300),
            ),

          // -------------------------------------
          // Draw gates
          // -------------------------------------
          for (final gate in gates)
            if (gate.type == "CNOT")
              ..._buildCNOT(gate)
            else
              _buildSingleGate(gate),
        ],
      ),
    );
  }

  // ============================================================
  // SINGLE-QUBIT GATE (colored box using AppColors)
  // ============================================================
  Widget _buildSingleGate(Gate gate) {
    final x = gate.position * gridSpacing - 30;
    final y = 50.0 + (gate.qubit * 80) - 30;

    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: _gateGradient(gate.type),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.richBlack.withOpacity(.20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            gate.type,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GRADIENT COLORS PER GATE TYPE
  // ============================================================
  LinearGradient _gateGradient(String type) {
    switch (type) {
      case "X":
        return const LinearGradient(
          colors: [AppColors.electricIndigo, AppColors.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case "H":
        return const LinearGradient(
          colors: [AppColors.quantumPink, AppColors.emberOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case "Z":
        return const LinearGradient(
          colors: [AppColors.ionGreen, AppColors.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case "Y":
        return const LinearGradient(
          colors: [AppColors.emberOrange, AppColors.helioYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      default:
        return const LinearGradient(colors: [Colors.black, Colors.black87]);
    }
  }

  // ============================================================
  // CNOT GATE (control dot + gradient target ⊕)
  // ============================================================
  List<Widget> _buildCNOT(Gate gate) {
    final controlY = 50.0 + (gate.qubit * 80);
    final targetY = 50.0 + ((gate.target ?? gate.qubit) * 80);
    final x = gate.position * gridSpacing;

    return [
      // Vertical line
      Positioned(
        left: x - 1,
        top: (controlY < targetY) ? controlY : targetY,
        child: Container(
          width: 2,
          height: (targetY - controlY).abs(),
          color: Colors.black,
        ),
      ),

      // Control dot
      Positioned(
        left: x - 6,
        top: controlY - 6,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
      ),

      // Target ⊕ with gradient
      Positioned(
        left: x - 16,
        top: targetY - 16,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: const LinearGradient(
              colors: [AppColors.electricIndigo, AppColors.quantumPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.richBlack.withOpacity(.20),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, size: 20, color: Colors.white),
          ),
        ),
      ),
    ];
  }
}

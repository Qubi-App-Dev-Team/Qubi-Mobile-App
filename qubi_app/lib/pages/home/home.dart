import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubi_app/pages/home/components/qubi_card.dart';
import 'package:qubi_app/pages/home/components/circuit_section.dart';
import 'package:qubi_app/pages/home/components/collapsible_section.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<CircuitSectionState> circuitKey =
      GlobalKey<CircuitSectionState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6EEF8),
        title: const Text(
          "My Qubis",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _buildTopButton('assets/icons/Add.svg'),
                const SizedBox(width: 8),
                _buildTopButton('assets/icons/Settings.svg'),
              ],
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Color(0xFFC7DDF0), height: 1.0),
        ),
      ),

      // 🧩 Use Stack so the drawer slides up from beneath the main content
      body: Stack(
        children: [
          // 🟢 Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 325,
                  child: ListView(
                    children: [
                      QubiCard(
                        title: "Qubi v1",
                        qubiColor: const Color(0xFF66E3C4),
                        qubitIndex: 0,
                        onGatePressed: (String gateType, int qubitIndex) {
                          List<int> qubits = gateType == "cx"
                              ? (qubitIndex == 0 ? [0,1] : [1,0])
                              : [qubitIndex];

                          circuitKey.currentState?.addGate(gateType, qubits);
                        },
                        onDeletePressed: (qubitIndex) {
                          circuitKey.currentState?.removeLastGate(qubitIndex);
                        },
                      ),
                      QubiCard(
                        title: "Qubi v1",
                        qubiColor: const Color(0xFF9D6CFF),
                        qubitIndex: 1,
                        onGatePressed: (String gateType, int qubitIndex) {
                          List<int> qubits = gateType == "cx"
                              ? (qubitIndex == 0 ? [0,1] : [1,0])
                              : [qubitIndex];

                          circuitKey.currentState?.addGate(gateType, qubits);
                        },
                        onDeletePressed: (qubitIndex) {
                          circuitKey.currentState?.removeLastGate(qubitIndex);
                        },
                      ),
                      // QubiCard(title: "Qubi v1", qubiColor: Colors.blue, qubitIndex: 2, onGatePressed: (gateType, qubit) => print("Pressed: $gateType"),),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // space before drawer starts
              ],
            ),
          ),

          // 🟣 Bottom drawer
          CircuitBottomDrawer(circuitKey: circuitKey),
        ],
      ),
    );
  }

  SizedBox _buildTopButton(String assetPath) {
    return SizedBox(
      height: 38,
      width: 38,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(1),
        child: SvgPicture.asset(
          assetPath,
          color: const Color(0xff000000),
          width: 20,
          height: 20,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Widget buildGradientButton(String label, bool outlined) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: outlined ? Border.all(color: Colors.white, width: 1.5) : null,
        color: outlined
            ? Colors.transparent
            : Colors.white.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Text(">", style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 25,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientText({
    super.key,
    required this.text,
    required this.colors,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

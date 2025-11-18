import 'package:flutter/material.dart';
import 'package:qubi_app/pages/profile/models/execution.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/home/components/dynamic_circuit.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:qubi_app/pages/home/components/loading_dialog.dart';

class CircuitSection extends StatelessWidget {
  const CircuitSection({super.key});

  Future<List<Gate>> loadCircuit() async {
    final data = await rootBundle.loadString('assets/circuit.json');
    final jsonData = json.decode(data);
    List gates = jsonData['gates'];
    return gates.map((g) => Gate.fromJson(g)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Sample executions — replace later with live backend data.

    final List<Execution> executionData = [
      Execution(
        success: true,
        status: "completed",
        circuitId: "test_circuit_001",
        quantumComputer: "ibm_hanoi",
        histogramCounts: {"00": 520, "01": 210, "10": 155, "11": 115},
        histogramProbabilities: {
          "00": 0.52,
          "01": 0.21,
          "10": 0.155,
          "11": 0.115,
        },
        time: 8.92,
        shots: 1000,
        createdAt: "2025-01-01T12:00:00Z",
        userId: "test_user_123",
      ),

      Execution(
        success: true,
        status: "completed",
        circuitId: "test_circuit_002",
        quantumComputer: "ionq_aria",
        histogramCounts: {"0": 113, "1": 87},
        histogramProbabilities: {"0": 0.565, "1": 0.435},
        time: 2.15,
        shots: 200,
        createdAt: "2025-01-02T16:30:00Z",
        userId: "test_user_123",
      ),

      Execution(
        success: false,
        status: "failed",
        circuitId: "test_circuit_003",
        quantumComputer: "simulator_qasm",
        histogramCounts: {},
        histogramProbabilities: {},
        time: 0.0,
        shots: 0,
        createdAt: "2025-01-03T08:42:00Z",
        userId: null,
      ),
    ];

    return Column(
      children: [
        // 🔹 Top gradient container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF6525FE), Color(0xFFF25F1C)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Last shake - IBM Hanoi (32 qubits)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RunPage(execution: executionData[0]),
                        ),
                      );
                    },
                    child: buildGradientButton("Read Report", true),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoryPage()),
                      );
                    },
                    child: buildGradientButton("Skip to Story", false),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 🔹 Pending circuit header
        Container(
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 5,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Circuit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                'View all >',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ),

        // 🔹 Circuit SVG image
        FutureBuilder<List<Gate>>(
          future: loadCircuit(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading circuit: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No circuit data found'),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: SizedBox(
                height: 200, // <-- NEW: ensures the colored circuit fits
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CircuitView(
                    gates: snapshot.data!,
                    numPositions: 12,
                    gridSpacing: 80,
                  ),
                ),
              ),
            );
          },
        ),

        // 🔹 Bottom gradient "Select Executor"
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF6525FE), Color(0xFF1A91FC)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select & Run",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),

              // Executor selector
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExecutorPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.black.withValues(alpha: .20),
                        const Color(0xFFF7FAFC).withValues(alpha: .20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "IBM Hanoi (32 qubits)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔸 Run Pending Circuit Button → shows loading then navigates
              GestureDetector(
                onTap: () async {
                  // show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const LoadingDialog(),
                  );

                  // wait for 5 seconds
                  await Future.delayed(const Duration(seconds: 5));

                  // close loading
                  if (context.mounted) Navigator.of(context).pop();

                  // navigate to RunPage
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RunPage(execution: executionData[1]),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Color(0xFFFF3B30), Color(0xFFFFC107)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Run Pending Circuit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Button builder helper
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
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
        ],
      ),
    );
  }
}

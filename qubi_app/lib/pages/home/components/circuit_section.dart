import 'package:flutter/material.dart';
import 'package:qubi_app/pages/profile/models/execution.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/home/components/dynamic_circuit.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:qubi_app/pages/home/components/loading_dialog.dart';
import 'dart:math' as math;

class CircuitSection extends StatefulWidget {
  const CircuitSection({super.key});

  @override
  State<CircuitSection> createState() => _CircuitSectionState();
}

class _CircuitSectionState extends State<CircuitSection> {
  late Future<List<Gate>> _futureGates;
  int circuitDepth = 0;
  late ScrollController _scrollController = ScrollController();

  Future<List<Gate>> loadCircuit() async {
    final data = await rootBundle.loadString('assets/circuit.json');
    final jsonData = json.decode(data);

    List<Map<String, dynamic>> gatesJson =
        List<Map<String, dynamic>>.from(jsonData['gates']);

    List<Gate> gates = List<Gate>.generate(
      gatesJson.length,
      (i) => Gate.fromJson(gatesJson[i], i),
    );

    circuitDepth = processGates(gates);
    return gates;
  }
  
  // getting position of each gate - to make un-staggered
  int processGates(List<Gate> gates) {
    final Map<int, int> nextFreeColumn = {};

    for (final gate in gates) {
      int assignedColumn = 0;
      final minQ = gate.qubits.reduce(math.min);
      final maxQ = gate.qubits.reduce(math.max);

      for (final q in gate.qubits) {
        assignedColumn = math.max(assignedColumn, (nextFreeColumn[q] ?? 0));
      }
      gate.position = assignedColumn; // assign column position to gate

      for (int q = minQ; q <= maxQ; q++) { 
        nextFreeColumn[q] = assignedColumn + 1; // get next free space for qubit q at assigned + 1
      }
    }

    return nextFreeColumn.values.fold(0, (a, b) => math.max(a, b)); // return depth of circuit
  }

  @override // init function with reading gates + getting depth
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _futureGates = loadCircuit().then((gates) {
      if (gates.isEmpty) throw Exception('No gates exist');
      return gates;
    });
  }

  @override // dispose to close scroll
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sample executions — replace later with live backend data.
    final List<Execution> executionData = [
      Execution(
        message: true,
        circuitId:
            "abe6d955a212c337fa16498d5a378782330be5dc65e1bbc404a41f87383f3119",
        runId: "Qv6DySvo3mjfiQLHkf8B",
        quantumComputer: "IBM",
        histogramCounts: {"00": 563, "01": 242, "10": 193, "11": 437},
        histogramProbabilities: {
          "00": 0.563,
          "01": 0.242,
          "10": 0.193,
          "11": 0.437,
        },
        time: 9.43,
        shots: 1000,
      ),
      Execution(
        message: true,
        circuitId: "ionq_002",
        runId: "IonQxG7DaA",
        quantumComputer: "IonQ",
        histogramCounts: {"0": 112, "1": 88},
        histogramProbabilities: {"0": 0.56, "1": 0.44},
        time: 2.12,
        shots: 200,
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
                  // "Read Report" → RunPage (with full model)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RunPage(execution: executionData[1], gates: [], circuitDepth: 0),
                        ),
                      );
                    },
                    child: buildGradientButton("Read Report", true),
                  ),
                  const SizedBox(width: 12),
                  // "Skip to Story"
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
              // Text(
              //   'View all >',
              //   style: TextStyle(fontSize: 15, color: Colors.black54),
              // ),
            ],
          ),
        ),

        // Circuit SVG image
        FutureBuilder<List<Gate>>(
          future: _futureGates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
            }

            final gates = snapshot.data;
            if (gates == null || gates.isEmpty) {
              return const Text('No circuit data found');
            }

            return SizedBox (
              width: double.infinity,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: circuitDepth <= 5 ? false : true,
                thickness: 4,
                radius: Radius.circular(8),
                interactive: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  physics: const BouncingScrollPhysics(),
                  child: CircuitView(gates: gates, circuitDepth: circuitDepth),
                ),
              )
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

                  // navigate to RunPage with valid gates
                  try {
                    final gates = await _futureGates;
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RunPage(execution: executionData[1], gates: gates, circuitDepth: circuitDepth),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load circuit: $e')),
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
                          fontSize: 17.5,
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

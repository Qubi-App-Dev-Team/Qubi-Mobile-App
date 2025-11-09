import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubi_app/pages/profile/models/execution.dart';
import 'package:qubi_app/pages/profile/models/execution_model.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/api/api_client.dart';
import 'package:qubi_app/user_bloc/stored_user_info.dart';

class CircuitSection extends StatefulWidget {
  const CircuitSection({super.key});

  @override
  State<CircuitSection> createState() => _CircuitSectionState();
}

class _CircuitSectionState extends State<CircuitSection> {
  bool _isSubmitting = false;

  // 🧩 Test circuit payload (temporary)
  final Map<String, dynamic> _testCircuit = const {
    "gates": [
      {"name": "h", "qubits": [0]},
      {"name": "cx", "qubits": [0, 1]},
      {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]},
    ],
    "num_qubits": 2,
    "num_clbits": 2,
  };

  //final List<Execution> executionData = [ Execution( message: true, circuitId: "abe6d955a212c337fa16498d5a378782330be5dc65e1bbc404a41f87383f3119", runId: "Qv6DySvo3mjfiQLHkf8B", quantumComputer: "IBM", histogramCounts: {"00": 563, "01": 242, "10": 193, "11": 437}, histogramProbabilities: { "00": 0.563, "01": 0.242, "10": 0.193, "11": 0.437, }, time: 9.43, shots: 1000, ), Execution( message: true, circuitId: "ionq_002", runId: "IonQxG7DaA", quantumComputer: "IonQ", histogramCounts: {"0": 112, "1": 88}, histogramProbabilities: {"0": 0.56, "1": 0.44}, time: 2.12, shots: 200, ), ];
  final List<ExecutionModel> executionData = [
    ExecutionModel(
      userId: "user_01",
      circuitId:
          "abe6d955a212c337fa16498d5a378782330be5dc65e1bbc404a41f87383f3119",
      quantumComputer: "IBM",
      histogramCounts: {"00": 563, "01": 242, "10": 193, "11": 437},
      histogramProbabilities: {
        "00": 0.563,
        "01": 0.242,
        "10": 0.193,
        "11": 0.437,
      },
      elapsedTimeS: 9.43,
      shots: 1000,
      success: true,
    ),
    ExecutionModel(
      userId: "user_01",
      circuitId: "ionq_002",
      quantumComputer: "IonQ",
      histogramCounts: {"0": 112, "1": 88},
      histogramProbabilities: {"0": 0.56, "1": 0.44},
      elapsedTimeS: 2.12,
      shots: 200,
      success: true,
    ),
  ];
  // Static metadata (for now)
  static const String _quantumComputer = "ionq_simulator";
  static const int _shots = 1000;

  

  @override
  Widget build(BuildContext context) {
    // Sample executions — placeholder data for static runs
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
                          builder: (_) => RunPage(execution: executionData[0]),
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
              Text(
                'View all >',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ),

        // 🔹 Circuit SVG image
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          width: double.infinity,
          child: SvgPicture.asset(
            'assets/images/circuit1.svg',
            height: 140,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
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

              // 🔸 Run Pending Circuit Button → Calls API + navigates
              GestureDetector(
                onTap: _isSubmitting ? null : _onRunPendingCircuit,
                child: Opacity(
                  opacity: _isSubmitting ? 0.6 : 1.0,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isSubmitting
                              ? "Starting run..."
                              : "Run Pending Circuit",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onRunPendingCircuit() async {
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final userId = StoredUserInfo.userID;

      // Call /make_request
      final runRequestId = await ApiClient.makeRequest(
        userId: userId,
        circuit: _testCircuit,
        quantumComputer: _quantumComputer,
        shots: _shots,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text("Run started! ID: $runRequestId")),
      );

      // Navigate to RunPage (RunPage will show LoadingDialog + poll)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RunPage(
            runRequestId: runRequestId,
            quantumComputer: _quantumComputer,
            shots: _shots,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text("Error running circuit: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

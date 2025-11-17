import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔹 Added import
import 'package:qubi_app/pages/profile/models/execution_model.dart';
import 'package:qubi_app/pages/profile/models/executor_config.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/profile/pages/executor_setup.dart';
import 'package:qubi_app/api/api_client.dart';
import 'package:qubi_app/user_bloc/stored_user_info.dart';

class CircuitSection extends StatefulWidget {
  const CircuitSection({super.key});

  @override
  State<CircuitSection> createState() => _CircuitSectionState();
}

class _CircuitSectionState extends State<CircuitSection> {
  bool _isSubmitting = false;
  ExecutorConfig? _executorConfig;
  String _selectedQuantumComputer = 'ionq_simulator';
  int _selectedShots = 1000;

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

  final List<Map<String, String>> _availableExecutors = [
    {'value': 'ionq_simulator', 'label': 'IonQ Simulator'},
    {'value': 'ibm_simulator', 'label': 'IBM Simulator'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExecutorConfig();
  }

  Future<void> _loadExecutorConfig() async {
    try {
      final userId = StoredUserInfo.userID;
      if (userId.isEmpty) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('settings')
          .doc('executor_config')
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _executorConfig = ExecutorConfig.fromJson(docSnapshot.data()!);
          _selectedQuantumComputer = _executorConfig!.defaultExecutor;
          _selectedShots = _executorConfig!.defaultShots;
        });
      }
    } catch (e) {
      // Silently fail and use default values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Top gradient container (unchanged)
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

        // 🔹 Pending circuit header (unchanged)
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

        // 🔹 Circuit SVG image (unchanged)
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

        // 🔹 Bottom gradient container (modified ONLY inside this block)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select & Run",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExecutorSetupPage(),
                        ),
                      ).then((_) => _loadExecutorConfig());
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.settings, size: 16, color: Colors.white70),
                        SizedBox(width: 4),
                        Text(
                          "Setup",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quantum Computer Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedQuantumComputer,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF6525FE),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    items: _availableExecutors.map((executor) {
                      return DropdownMenuItem<String>(
                        value: executor['value'],
                        child: Text(executor['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedQuantumComputer = value!);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Shots Input
              Row(
                children: [
                  const Text(
                    "Shots:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'e.g., 1000',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        controller: TextEditingController(
                          text: _selectedShots.toString(),
                        )..selection = TextSelection.fromPosition(
                            TextPosition(offset: _selectedShots.toString().length),
                          ),
                        onChanged: (value) {
                          final shots = int.tryParse(value);
                          if (shots != null && shots > 0) {
                            _selectedShots = shots;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 🔸 🔹 ONLY THIS PART BELOW IS NEW 🔹 🔸
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(StoredUserInfo.userID)
                    .snapshots(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?.data();
                  final currentRunId = userData?['current_run_request_id'];

                  // CASE 1 → Run in progress
                  if (currentRunId != null) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RunPage(runRequestId: currentRunId),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Color(0xFFFF8A00), Color(0xFFFFC107)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Run in progress",
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
                    );
                  }

                  // CASE 2 → No run in progress (default behavior)
                  return GestureDetector(
                    onTap: _isSubmitting ? null : _onRunPendingCircuit,
                    child: Opacity(
                      opacity: _isSubmitting ? 0.6 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
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
                  );
                },
              ),
              // 🔸 🔹 END OF NEW CODE 🔹 🔸
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

      // Prepare API keys if available
      Map<String, String>? apiKeys;
      if (_executorConfig != null) {
        apiKeys = {};
        if (_executorConfig!.ionqApiKey != null && _executorConfig!.ionqApiKey!.isNotEmpty) {
          apiKeys['ionq'] = _executorConfig!.ionqApiKey!;
        }
        if (_executorConfig!.ibmApiKey != null && _executorConfig!.ibmApiKey!.isNotEmpty) {
          apiKeys['ibm'] = _executorConfig!.ibmApiKey!;
        }
        if (apiKeys.isEmpty) apiKeys = null;
      }

      // Call /make_request with selected quantum computer, shots, and API keys
      final runRequestId = await ApiClient.makeRequest(
        userId: userId,
        circuit: _testCircuit,
        quantumComputer: _selectedQuantumComputer,
        shots: _selectedShots,
        apiKeys: apiKeys,
      );

      if (!mounted) return;

      // ✅ Show snackbar only for an initial run (not returning to progress)
      messenger.showSnackBar(
        SnackBar(content: Text("Circuit successfully sent to $_selectedQuantumComputer")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RunPage(
            runRequestId: runRequestId,
            quantumComputer: _selectedQuantumComputer,
            shots: _selectedShots,
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

  // 🔹 Button builder helper (unchanged)
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

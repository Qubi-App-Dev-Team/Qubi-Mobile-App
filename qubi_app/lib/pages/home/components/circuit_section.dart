import 'package:flutter/material.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/home/components/dynamic_circuit.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qubi_app/pages/profile/models/execution_model.dart';
import 'package:qubi_app/api/api_client.dart';
import 'package:qubi_app/user_bloc/stored_user_info.dart';

class CircuitSection extends StatefulWidget {
  const CircuitSection({super.key});

  @override
  State<CircuitSection> createState() => CircuitSectionState();
}

class CircuitSectionState extends State<CircuitSection> {
  List<Gate> _gates = [];
  // late Future<List<Gate>> _futureGates;
  int circuitDepth = 0;
  late final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  DateTime? _shakeLoadStart;
  int _minShimmerMs = 1800; // 1.8 seconds minimum
  ExecutionModel? _lastShake;
  bool _requestedLastShake = false;
  bool _loadingLastShake = true;

  // loading circuit from specified json - gates can still be added with frontend buttons
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

  // function for adding gates incrementally from frontend buttons
  void addGate(String type, List<int> qubits) {
    setState(() {
      _gates.add(Gate(type: type, qubits: qubits, position: 0));
      circuitDepth = processGates(_gates);
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // function for removing gates from specified index from frontend buttons
  void removeLastGate(int qubitIndex) {
    setState(() {
      for (int i = _gates.length - 1; i >= 0; i--) {
        if (_gates[i].qubits.contains(qubitIndex)) {
          _gates.removeAt(i);
          break;
        }
      }
      circuitDepth = processGates(_gates);
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /*
  Future<void> _loadLastShake() async {
    try {
      setState(() => _loadingLastShake = true);

      final result = await ApiClient.fetchLastShake();
      if (!mounted) return;
      setState(() {
        _lastShake = result;
        _loadingLastShake = false;
      });
    } catch (e) {
      if (!mounted) return;
      print("[CircuitSection] Failed to load last shake: $e");
      setState(() => _loadingLastShake = false);
    }
  }*/

  Future<void> _loadLastShake() async {
    try {
      _shakeLoadStart = DateTime.now();
      setState(() => _loadingLastShake = true);

      final result = await ApiClient.fetchLastShake();
      if (!mounted) return;

      final elapsed = DateTime.now().difference(_shakeLoadStart!).inMilliseconds;
      final remaining = _minShimmerMs - elapsed;

      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }

      if (!mounted) return;

      setState(() {
        _lastShake = result;
        _loadingLastShake = false;
      });
    } catch (e) {
      if (!mounted) return;
      print("[CircuitSection] Failed to load last shake: $e");

      setState(() => _loadingLastShake = false);
    }
  }

  // init function reading gates and loading last shake
  @override
  void initState() {
    super.initState();
    loadCircuit().then((gates) {
      setState(() {
        _gates = gates;
      });
    });
    _loadLastShake();
  }

  // dispose to close scroll
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final Map<String, dynamic> _testCircuit = const {
    "gates": [
      {"name": "h", "qubits": [0]},
      {"name": "cx", "qubits": [0, 1]},
      {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]},
    ],
    "num_qubits": 2,
    "num_clbits": 2,
  };

  static const String _quantumComputer = "ionq";
  static const int _shots = 1000;

  // -------------------------------------------------------------------------
  // TOP CARD WITH SHIMMER (ONLY PLACE WHERE UI IS MODIFIED)
  // -------------------------------------------------------------------------
  Widget _buildTopCard() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _loadingLastShake
              ? "Loading last shake..."
              : _lastShake == null
                  ? "No shakes yet"
                  : "Last shake - ${_lastShake!.quantumComputer}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _lastShake == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RunPage(execution: _lastShake!, gates: _gates, circuitDepth: circuitDepth),
                        ),
                      );
                    },
              child: buildGradientButton(
                _lastShake == null ? "No report" : "Read Report",
                true,
              ),
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
    );

    return Container(
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

      // ✨ SHIMMER ONLY WHEN LOADING
      child: _loadingLastShake
          ? Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.8),
              highlightColor: Colors.white.withValues(alpha: 1),
              child: content,
            )
          : content,
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Column(
      children: [
        _buildTopCard(),
        
        // 🔹 Pending circuit header
        Container(
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 5,
          ),
          child: Row( 
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
              Row(
                children: [
                  IconButton( // back scroll button
                    icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black54),
                    onPressed: () {
                      final double newOffset = _scrollController.offset - 100;
                      _scrollController.animateTo(
                        newOffset.clamp(0, _scrollController.position.maxScrollExtent),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  IconButton( // forward scroll button
                    icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
                    onPressed: () {
                      final double newOffset = _scrollController.offset + 100;
                      _scrollController.animateTo(
                        newOffset.clamp(0, _scrollController.position.maxScrollExtent),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                ]
              )
            ],
          ),
        ),

        // Circuit SVG image
        buildCircuitDisplay(),

        // ---------------- BOTTOM CARD (UNCHANGED) ----------------
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
                        "IonQ Aria",
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

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('run_requests')
                    .where('user_id', isEqualTo: StoredUserInfo.userID)
                    .where('status', whereIn: ['PENDING', 'RUNNING'])
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    if (!_requestedLastShake) {
                      _requestedLastShake = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadLastShake();
                      });
                    }
                  } else {
                    _requestedLastShake = false;
                  }

                  if (docs.isNotEmpty) {
                    final runRequestId = docs.first.id;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RunPage(runRequestId: runRequestId, gates: _gates, circuitDepth: circuitDepth),
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
                            Icon(Icons.play_arrow_rounded,
                                size: 20, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  }

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
                                  ? "Starting..."
                                  : "Run Pending Circuit",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(Icons.play_arrow_rounded,
                                size: 20, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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

      final runRequestId = await ApiClient.makeRequest(
        userId: userId,
        circuit: _testCircuit,
        quantumComputer: _quantumComputer,
        shots: _shots,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text("Circuit successfully sent to $_quantumComputer")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RunPage(
            runRequestId: runRequestId,
            quantumComputer: _quantumComputer,
            shots: _shots,
            gates: _gates, 
            circuitDepth: circuitDepth
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

  Widget buildGradientButton(String label, bool outlined) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: outlined ? Border.all(color: Colors.white, width: 1.5) : null,
        color: outlined ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
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

  Widget buildCircuitDisplay() {
    if (_gates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('no circuit', style: TextStyle(fontSize: 14, color: Colors.black54)),
      );
    } else {
      return SizedBox (
        width: double.infinity,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          physics: const BouncingScrollPhysics(),
          child: CircuitView(gates: _gates, circuitDepth: circuitDepth),
        ),
      );
    }
  }
}

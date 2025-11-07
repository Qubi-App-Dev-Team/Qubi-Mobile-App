import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubi_app/pages/profile/models/execution.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/home/components/loading_dialog.dart';
import 'package:qubi_app/services/quantum_api.dart';

class CircuitSection extends StatelessWidget {
  const CircuitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _recentRunCard(context),
        _pendingHeader(),
        _circuitImage(),
        _executorCard(context),
      ],
    );
  }

  // --- Top card showing last run summary
  Widget _recentRunCard(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF6525FE), Color(0xFFF25F1C)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
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
                // Placeholder: navigate when you have stored runs
              },
              child: _gradientButton("Read Report", true),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoryPage()),
                );
              },
              child: _gradientButton("Skip to Story", false),
            ),
          ],
        ),
      ],
    ),
  );

  // --- Section header
  Widget _pendingHeader() => Container(
    margin: const EdgeInsets.fromLTRB(16, 10, 16, 5),
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
  );

  // --- Display circuit image
  Widget _circuitImage() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    width: double.infinity,
    child: SvgPicture.asset(
      'assets/images/circuit1.svg',
      height: 140,
      fit: BoxFit.contain,
    ),
  );

  // --- Executor and Run button
  Widget _executorCard(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF6525FE), Color(0xFF1A91FC)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExecutorPage()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _runPendingCircuitButton(context),
      ],
    ),
  );

  // --- Run Pending Circuit
  Widget _runPendingCircuitButton(BuildContext context) => GestureDetector(
    onTap: () async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LoadingDialog(),
      );

      try {
        final requestBody = {
          "user_id": "user_01",
          "shots": 1000,
          "quantum_computer": "ionq_simulator",
          "circuit": {
            "gates": [
              {
                "name": "h",
                "qubits": [0],
              },
              {
                "name": "cx",
                "qubits": [0, 1],
              },
              {
                "name": "measure",
                "qubits": [0, 1],
                "clbits": [0, 1],
              },
            ],
            "num_qubits": 2,
            "num_clbits": 2,
          },
        };

        final circuitId = await QuantumAPI.makeRequest(requestBody);
        Execution? execution;

        if (circuitId != null) {
          execution = await QuantumAPI.fetchResults(circuitId);
        }

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          if (execution != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RunPage(execution: execution!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Run timed out or no results returned.'),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    },

    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
        ],
      ),
    ),
  );

  // --- Reusable gradient button
  Widget _gradientButton(String label, bool outlined) => Container(
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

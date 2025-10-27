import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubi_app/pages/home/executor.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/run.dart';

class CircuitSection extends StatelessWidget {
  const CircuitSection({super.key});

  @override
  Widget build(BuildContext context) {
    // You can later replace these with live circuit/execution data if needed.
    final List<Map<String, dynamic>> executionData = [
      {
        "name": "IBM Hanoi",
        "status": "sent",
        "time": "27 Oct 2025 2:41 AM",
        "hardware": "IBM",
        "totalTime": "9.43s",
        "pendingTime": "8s",
        "executionTime": "1s",
        "perShot": "0.001s",
        "circuitDepth": "5",
        "resultCount": "1000",
        "results": {"00": 563, "01": 242, "10": 193, "11": 437},
      },
      {
        "name": "IonQ Harmony",
        "status": "crafted",
        "time": "26 Oct 2025 5:10 PM",
        "hardware": "IonQ",
        "totalTime": "2.12s",
        "pendingTime": "1.2s",
        "executionTime": "0.9s",
        "perShot": "0.002s",
        "circuitDepth": "3",
        "resultCount": "200",
        "results": {"0": 112, "1": 88},
      },
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
              colors: [
                Color(0xFF6525FE), // purple
                Color(0xFFF25F1C), // orange
              ],
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
                  // "Read Report" → RunPage (with full data)
                  GestureDetector(
                    onTap: () {
                      final item = executionData[0];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RunPage(
                            name: item["name"],
                            status: item["status"],
                            time: item["time"],
                            hardware: item["hardware"],
                            totalTime: item["totalTime"],
                            pendingTime: item["pendingTime"],
                            executionTime: item["executionTime"],
                            perShot: item["perShot"],
                            circuitDepth: item["circuitDepth"],
                            resultCount: item["resultCount"],
                            results: Map<String, int>.from(item["results"]),
                          ),
                        ),
                      );
                    },

                    child: buildGradientButton("Read Report", true),
                  ),

                  const SizedBox(width: 12),

                  // "Skip to Story" (→ StoryPage)
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
              colors: [
                Color(0xFF6525FE), // purple
                Color(0xFF1A91FC), // blue
              ],
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

              // 🔸 Run Pending Circuit Button → new RunPage (same data)
              GestureDetector(
                onTap: () {
                  final item = executionData[1];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RunPage(
                        name: item["name"],
                        status: item["status"],
                        time: item["time"],
                        hardware: item["hardware"],
                        totalTime: item["totalTime"],
                        pendingTime: item["pendingTime"],
                        executionTime: item["executionTime"],
                        perShot: item["perShot"],
                        circuitDepth: item["circuitDepth"],
                        resultCount: item["resultCount"],
                        results: Map<String, int>.from(item["results"]),
                      ),
                    ),
                  );
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

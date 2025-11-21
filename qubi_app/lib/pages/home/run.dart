import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qubi_app/pages/profile/models/execution.dart';
import 'package:qubi_app/pages/story/story_page.dart';
import 'package:qubi_app/pages/home/components/dynamic_circuit.dart';

class RunPage extends StatefulWidget {
  final Execution execution;
  final List<Gate> gates;
  final int circuitDepth; 

  const RunPage({super.key, required this.execution, required this.gates, required this.circuitDepth});

  @override
  State<StatefulWidget> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.execution.histogramCounts;
    final totalShots = widget.execution.shots.toString();
    final runTime = "${widget.execution.time.toStringAsFixed(3)} s";
    final ScrollController scrollController = ScrollController();  

    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF8),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Color(0xFFC7DDF0), height: 1, thickness: 1),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryPage()),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6525FE), Color(0xFF1A91FC)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  "See the story of this run  ›",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6EEF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Run",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_horiz, color: Colors.black),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFC7DDF0), height: 1),
        ),
      ),

      // ------------------------------------------------------------
      // Body
      // ------------------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _executorCard(),
            const SizedBox(height: 20),
            _circuitCard(scrollController),
            const SizedBox(height: 12),
            _resultsCard(results, totalShots, runTime),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // EXECUTOR INFO CARD
  // ----------------------------------------------------------
  Widget _executorCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _donutPill(),
            const SizedBox(width: 10),
            Row(
              children: [
                const Text(
                  "›",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.execution.quantumComputer,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // ----------------------------------------------------------
  // CIRCUIT CARD (placeholder image)
  // ----------------------------------------------------------
  Widget _circuitCard(ScrollController scrollController) => Container(
    width: double.infinity,
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Circuit Depth: ${widget.circuitDepth}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  IconButton( // back scroll button
                    icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black54),
                    onPressed: () {
                      final double newOffset = scrollController.offset - 200;
                      scrollController.animateTo(
                        newOffset.clamp(0, scrollController.position.maxScrollExtent),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  IconButton( // forward scroll button
                    icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
                    onPressed: () {
                      final double newOffset = scrollController.offset + 200;
                      scrollController.animateTo(
                        newOffset.clamp(0, scrollController.position.maxScrollExtent),
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

        const Divider(color: Color(0xFFE0E6ED), height: 1),
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              physics: const BouncingScrollPhysics(),
              child: CircuitView(gates: widget.gates, circuitDepth: widget.circuitDepth),
            ),
          ),
      ],
    ),
  );

  // ----------------------------------------------------------
  // RESULTS CARD — histogram
  // ----------------------------------------------------------
  Widget _resultsCard(
    Map<String, int> results,
    String totalShots,
    String runTime,
  ) {
    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text(
            "No result data available.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final entries = results.entries.toList();
    final maxY = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 10),
            child: Text(
              "Results (shots distribution)",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entries[index].key,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < entries.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: entries[i].value.toDouble(),
                          width: 22,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6525FE), Color(0xFF1A91FC)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
                maxY: maxY * 1.1,
              ),
              swapAnimationDuration: const Duration(milliseconds: 900),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total shots: $totalShots",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Run time: $runTime",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  Widget _donutPill() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEDEFF2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF66E3C4), width: 3.5),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF9D6CFF), width: 3.5),
          ),
        ),
      ],
    ),
  );
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qubi_app/pages/profile/models/execution_model.dart'; // ⬅️ unified model
import 'package:qubi_app/pages/story/story_page.dart';

class RunPage extends StatefulWidget {
  final ExecutionModel? execution; // old flow now uses ExecutionModel
  final String? runRequestId; // new flow
  final String? quantumComputer;
  final int? shots;

  const RunPage({
    super.key,
    this.execution,
    this.runRequestId,
    this.quantumComputer,
    this.shots,
  });

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  StreamSubscription<DocumentSnapshot>? _listener;
  bool _isLoading = false;
  Map<String, int> _histogramCounts = {};
  double? _elapsedTime; // null until result arrives
  int _shots = 0;
  String _quantumComputer = "";

  @override
  void initState() {
    super.initState();

    // Old static path (now ExecutionModel)
    if (widget.execution != null) {
      final e = widget.execution!;
      _histogramCounts = e.histogramCounts ?? {};
      _elapsedTime = e.elapsedTimeS; // ⬅️ was e.time
      _shots = e.shots ?? 0;
      _quantumComputer = e.quantumComputer ?? "";
    }
    // New Firestore path
    else if (widget.runRequestId != null) {
      _quantumComputer = widget.quantumComputer ?? "";
      _shots = widget.shots ?? 0;
      _listenForResults(widget.runRequestId!);
    }
  }

  void _listenForResults(String runRequestId) {
    setState(() => _isLoading = true);

    _listener = FirebaseFirestore.instance
        .collection('run_results')
        .doc(runRequestId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;

      if (data['success'] == true && mounted) {
        setState(() {
          _isLoading = false;
          _histogramCounts =
              Map<String, int>.from(data['histogram_counts'] ?? {});
          _elapsedTime = (data['elapsed_time_s'] ?? 0).toDouble();
          _quantumComputer = data['quantum_computer'] ?? '';
          _shots = (data['shots'] ?? 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _histogramCounts;
    final totalShots = _shots.toString();
    final runTime =
        _elapsedTime == null ? "-" : "${_elapsedTime!.toStringAsFixed(3)} s";

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
        title: const Text(
          "Your Run",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFC7DDF0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _executorCard(),
            const SizedBox(height: 20),
            _circuitCard(),
            const SizedBox(height: 12),
            _resultsCard(results, totalShots, runTime),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // EXECUTOR CARD
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
                Text(
                  _quantumComputer.isNotEmpty
                      ? _quantumComputer
                      : "Waiting for executor...",
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
      );

  // ----------------------------------------------------------
  // CIRCUIT CARD
  // ----------------------------------------------------------
  Widget _circuitCard() => Container(
        width: double.infinity,
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                "Circuit",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(color: Color(0xFFE0E6ED), height: 1),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: SvgPicture.asset(
                'assets/images/circuit1.svg',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );

  // ----------------------------------------------------------
  // RESULTS CARD — spinner shown only in graph section
  // ----------------------------------------------------------
  Widget _resultsCard(Map<String, int> results, String shotsStr, String time) {
    final hasResults = results.isNotEmpty;

    final maxVal = hasResults
        ? results.values.reduce(max)
        : 0; // dummy for axis when waiting
    final step = _niceStep(maxVal);
    final chartMaxY = hasResults ? _niceCeil(maxVal * 1.1, step) : 100.0;

    final entries = results.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    final List<BarChartGroupData> barGroups = hasResults
    ? [
        for (int i = 0; i < entries.length; i++)
          BarChartGroupData(
            x: i,
            showingTooltipIndicators: const [0],
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
          )
      ]
    : <BarChartGroupData>[];

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
            child: hasResults
                ? BarChart(
                    BarChartData(
                      maxY: chartMaxY,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                      groupsSpace: 18,
                      barTouchData: BarTouchData(
                        enabled: true,
                        handleBuiltInTouches: false,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 6,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toInt().toString(),
                              const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: step.toDouble(),
                            reservedSize: 36,
                            getTitlesWidget: (value, _) {
                              final v = value.toInt();
                              if (v % step != 0) return const SizedBox.shrink();
                              return Text(
                                "$v",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= entries.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  entries[i].key,
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
                      barGroups: barGroups,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 900),
                    swapAnimationCurve: Curves.easeOutCubic,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 16),
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF6525FE)),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Waiting for results from quantum computer…",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total shots: $shotsStr",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Run time: $time",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
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

  Widget _messageCard(String message) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );

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

  int _niceStep(int maxValue) {
    if (maxValue <= 10) return 2;
    if (maxValue <= 25) return 5;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 250) return 50;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    return 500;
  }

  double _niceCeil(double value, int step) {
    final v = value.ceil();
    final m = (v + step - 1) ~/ step;
    return (m * step).toDouble();
  }
}

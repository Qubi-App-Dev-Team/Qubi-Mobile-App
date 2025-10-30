import 'package:flutter/material.dart';
import 'package:qubi_app/assets/app_colors.dart';
import 'package:qubi_app/pages/home/run.dart';
import 'package:qubi_app/pages/profile/models/execution.dart'; // new model import

class ExecHistoryPage extends StatefulWidget {
  const ExecHistoryPage({super.key});

  @override
  State<ExecHistoryPage> createState() => _ExecHistoryPageState();
}

class _ExecHistoryPageState extends State<ExecHistoryPage> {
  bool filterSentOut = false;
  List<String> selectedHardware = [];
  DateTime? selectedDate;

  // ----------------------------------------------
  // Replace maps with strongly typed Executions
  // ----------------------------------------------
  final List<Execution> allExecutions = [
    Execution(
      message: true,
      circuitId:
          "abe6d955a212c337fa16498d5a378782330be5dc65e1bbc404a41f87383f3119",
      runId: "Qv6DySvo3mjfiQLHkf8B",
      quantumComputer: "IonQ",
      histogramCounts: {"00": 490, "11": 510},
      histogramProbabilities: {"00": 0.5, "11": 0.5},
      time: 6.535945208001067,
      shots: 1000,
    ),
    Execution(
      message: true,
      circuitId: "xyzzza11",
      runId: "A12SDd891",
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
  ];

  List<Execution> get filteredExecutions {
    return allExecutions.where((exec) {
      if (filterSentOut && exec.quantumComputer.contains("simulator")) {
        return false; // exclude simulator if filtering real runs
      }
      if (selectedHardware.isNotEmpty &&
          !selectedHardware.contains(exec.hardwareDisplayName)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _openFilterPanel() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black26,
        pageBuilder: (_, __, ___) => _FilterPanel(
          filterSentOut: filterSentOut,
          selectedHardware: selectedHardware,
          selectedDate: selectedDate,
          onApply: (sent, hardware, date) {
            setState(() {
              filterSentOut = sent;
              selectedHardware = hardware;
              selectedDate = date;
            });
          },
        ),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.saltWhite,
      appBar: AppBar(
        backgroundColor: AppColors.saltWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Past Executions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.richBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.richBlack),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _openFilterPanel,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Filters",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.filter_alt_outlined, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredExecutions.length,
          itemBuilder: (context, i) =>
              _executionCard(context, filteredExecutions[i]),
        ),
      ),
    );
  }

  Widget _executionCard(BuildContext context, Execution exec) {
    final bool isSimulator = exec.quantumComputer.contains("simulator");
    final Color badgeColor = isSimulator
        ? AppColors.emberOrange
        : AppColors.ionGreen;
    final String badgeText = isSimulator ? "Simulated" : "Real";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RunPage(execution: exec)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.saltWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(
                Icons.memory_rounded,
                color: AppColors.electricIndigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exec.quantumComputer,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Shots: ${exec.shots} • Time: ${exec.time.toStringAsFixed(2)}s",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatefulWidget {
  final bool filterSentOut;
  final List<String> selectedHardware;
  final DateTime? selectedDate;
  final Function(bool, List<String>, DateTime?) onApply;

  const _FilterPanel({
    required this.filterSentOut,
    required this.selectedHardware,
    required this.selectedDate,
    required this.onApply,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late bool sentOut;
  late List<String> hardware;
  DateTime? date;

  // Define the fixed hardware categories
  final List<String> availableHardware = ["IBM", "IonQ", "Simulated"];

  @override
  void initState() {
    super.initState();
    sentOut = widget.filterSentOut;
    hardware = List.from(widget.selectedHardware);
    date = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Gradient header
                    Container(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 12,
                        right: 16,
                        bottom: 12,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6525FE), Color(0xFFF25F1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Filters",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              "Sent out",
                              onClear: () => setState(() => sentOut = false),
                            ),
                            CheckboxListTile(
                              value: sentOut,
                              onChanged: (v) =>
                                  setState(() => sentOut = v ?? false),
                              title: const Text(
                                "Sent to real quantum computers only",
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            const Divider(),

                            _sectionHeader(
                              "Select hardware",
                              onClear: () => setState(() => hardware.clear()),
                            ),

                            // ✅ Fixed hardware options
                            ...availableHardware.map((name) {
                              return CheckboxListTile(
                                value: hardware.contains(name),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      hardware.add(name);
                                    } else {
                                      hardware.remove(name);
                                    }
                                  });
                                },
                                title: Text(name),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }),

                            const Divider(),

                            _sectionHeader(
                              "Date",
                              onClear: () => setState(() => date = null),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: date ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => date = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F8FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      date == null
                                          ? "Select date..."
                                          : "${date!.day} ${_monthName(date!.month)} ${date!.year}",
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Apply button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF1A91FC),
                    onPressed: () {
                      widget.onApply(sentOut, hardware, date);
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        TextButton(onPressed: onClear, child: const Text("Clear")),
      ],
    );
  }

  String _monthName(int m) => [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sept",
    "Oct",
    "Nov",
    "Dec",
  ][m - 1];
}

import 'package:flutter/material.dart';
import 'package:qubi_app/assets/app_colors.dart';
import 'package:qubi_app/pages/home/run.dart';

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
  // In _ExecHistoryPageState
  // ----------------------------------------------
  final allExecutions = [
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
      "results": [
        {"00": 563},
        {"01": 242},
        {"10": 193},
        {"11": 437},
      ],
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
      // only two outcomes (1 qubit)
      "results": [
        {"0": 112},
        {"1": 88},
      ],
    },
    {
      "name": "IBH Hanoi",
      "status": "sent",
      "time": "25 Oct 2025 9:01 PM",
      "hardware": "IBH",
      "totalTime": "15.3s",
      "pendingTime": "13s",
      "executionTime": "2.3s",
      "perShot": "0.004s",
      "circuitDepth": "6",
      "resultCount": "1000",
      // 3-qubit, 8 outcomes
      "results": [
        {"000": 122},
        {"001": 136},
        {"010": 104},
        {"011": 110},
        {"100": 129},
        {"101": 128},
        {"110": 134},
        {"111": 117},
      ],
    },
  ];

  List<Map<String, Object>> get filteredExecutions {
    return allExecutions.where((item) {
      if (filterSentOut && item["status"] != "sent") return false;
      if (selectedHardware.isNotEmpty &&
          !selectedHardware.contains(item["hardware"])) {
        return false;
      }
      if (selectedDate != null &&
          !(item["time"]! as String).contains(
            "${selectedDate!.day} ${_monthName(selectedDate!.month)}",
          )) {
        return false;
      }
      return true;
    }).toList();
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

  Widget _executionCard(BuildContext context, Map<String, Object> item) {
    final bool sent = item["status"] == "sent";
    final Color badgeColor = sent ? AppColors.ionGreen : AppColors.emberOrange;
    final String badgeText = sent ? "Sent" : "Crafted";

    return GestureDetector(
      onTap: () {
        // Build results map from array of maps
        final List<dynamic>? histoArray = item["results"] as List<dynamic>;
        final Map<String, int> resultsMap = {};

        if (histoArray != null) {
          for (final entry in histoArray) {
            if (entry is Map<String, dynamic>) {
              entry.forEach((key, value) {
                resultsMap[key] = value is int
                    ? value
                    : int.tryParse(value.toString()) ?? 0;
              });
            }
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RunPage(
              name: item["name"]! as String,
              status: item["status"]! as String,
              time: item["time"]! as String,
              hardware: item["hardware"]! as String,
              totalTime: item["totalTime"] as String,
              pendingTime: item["pendingTime"] as String,
              executionTime: item["executionTime"] as String,
              perShot: item["perShot"] as String,
              circuitDepth: item["circuitDepth"] as String,
              resultCount: item["resultCount"] as String,
              results: resultsMap,
            ),
          ),
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
                    item["name"]! as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["time"]! as String,
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
                          colors: [
                            AppColors.electricIndigo,
                            AppColors.emberOrange,
                          ],
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
                            ...["IBM", "IonQ", "Simulated"].map((name) {
                              return CheckboxListTile(
                                value: hardware.contains(name),
                                onChanged: (v) {
                                  setState(() {
                                    v!
                                        ? hardware.add(name)
                                        : hardware.remove(name);
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
                                if (picked != null)
                                  setState(() => date = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.saltWhite,
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

                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.skyBlue,
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
            color: AppColors.richBlack,
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

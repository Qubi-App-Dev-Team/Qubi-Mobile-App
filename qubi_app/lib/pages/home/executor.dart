import 'package:flutter/material.dart';
import 'package:qubi_app/pages/home/components/executor_card.dart';

class ExecutorPage extends StatelessWidget {
  const ExecutorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6EEF8),
        elevation: 0,
        title: const Text(
          "Available Executors",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_horiz, size: 25, color: Colors.black),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFC7DDF0), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExecutorCard(
            name: "IBM Hanoi",
            subtitle: "32 qubits • Transmon architecture",
            details: "Queue: 3 jobs • Est. wait: 2m 30s",
            isActive: true,
            onTap: () => debugPrint("Use this executor"),
            onOptionsTap: () => debugPrint("Show options"),
          ),
          ExecutorCard(
            name: "IonQ Aria",
            subtitle: "25 qubits • Trapped-ion system",
            details: "Queue: 8 jobs • Est. wait: 6m 10s",
            isActive: true,
            onTap: () => debugPrint("Setup Access"),
          ),
          ExecutorCard(
            name: "Rigetti Aspen-M",
            subtitle: "24 qubits • Superconducting architecture",
            details: "Queue: 12 jobs • Est. wait: 8m 45s",
            isActive: false,
            onTap: () => debugPrint("Setup Access"),
          ),
        ],
      ),
    );
  }
}

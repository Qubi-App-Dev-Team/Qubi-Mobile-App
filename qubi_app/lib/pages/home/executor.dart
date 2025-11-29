import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qubi_app/pages/home/components/executor_card.dart';

class ExecutorPage extends StatefulWidget {
  const ExecutorPage({super.key});

  @override
  State<ExecutorPage> createState() => _ExecutorPageState();
}

class _ExecutorPageState extends State<ExecutorPage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, bool> executorAccess = {}; // checking if api key exists already
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get();
    setState(() {
      executorAccess = {
        "IBM Hanoi": (doc.data()?["ibm_api_tok"] ?? '').toString().isNotEmpty,
        "IonQ Aria": (doc.data()?["ionq_api_tok"] ?? '').toString().isNotEmpty,
      };
      loading = false;
    });
  }

  void handleExecutorTap(String name) {
    String field = "";
    switch (name) {
      case "IBM Hanoi":
        field = "ibm_api_tok";
        break;
      case "IonQ Aria":
        field = "ionq_api_tok";
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        // Prefill the TextField with the existing API key
        FirebaseFirestore.instance.collection("Users").doc(uid).get().then((doc) {
          final existingKey = doc.data()?[field]?.toString() ?? '';
          controller.text = existingKey;
        });

        return AlertDialog(
          title: Text("Access for $name"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter API Key"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(uid)
                      .set({field: controller.text}, SetOptions(merge: true));
                  setState(() {
                    executorAccess[name] = controller.text.isNotEmpty;
                  });
                  Navigator.pop(context);
                } catch (e) {
                  debugPrint("Error saving API key: $e");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6EEF8),
        elevation: 0,
        title: const Text(
          "Available Executors",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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
            details: "",
            isActive: executorAccess["IBM Hanoi"] ?? false,
            onTap: () {
              // Only open dialog if executor is inactive
              if (!(executorAccess["IBM Hanoi"] ?? false)) {
                handleExecutorTap("IBM Hanoi");
              } else {
                debugPrint("Using IBM Hanoi executor"); // actual use logic
              }
            },
            onOptionsTap: () => handleExecutorTap("IBM Hanoi"), //edit api key
          ),
          ExecutorCard(
            name: "IonQ Aria",
            subtitle: "25 qubits • Trapped-ion system",
            details: "",
            isActive: executorAccess["IonQ Aria"] ?? false,
            onTap: () {
              if (!(executorAccess["IonQ Aria"] ?? false)) {
                handleExecutorTap("IonQ Aria");
              } else {
                debugPrint("Using IonQ Aria executor");
              }
            },
            onOptionsTap: () => handleExecutorTap("IonQ Aria"), //edit api key
          ),
        ],
      ),
    );
  }
}

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
  Map<String, bool> executorAccess = {};   // checking if api key exists already
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    setState(() {
      executorAccess = {
        "IBM Hanoi": (doc.data()?["ibm_api_tok"] ?? '').toString().isNotEmpty,
        "IonQ Aria": (doc.data()?["ionq_api_tok"] ?? '').toString().isNotEmpty,
        "Rigetti Aspen-M": (doc.data()?["rigetti_api_tok"] ?? '').toString().isNotEmpty,
      };
      loading = false;
    });
  }

  void handleExecutorTap(String name) {
    final access = executorAccess[name];
    String field = "";
    
    switch (name) {
      case "IBM Hanoi":
        field = "ibm_api_tok";
      case "IonQ Aria": 
        field = "ionq_api_tok";
      case "Rigetti Aspen-M":
        field = "rigetti_api_tok";
    }

    if (access == true) {
      debugPrint("Already set up access");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text("Setup Access for $name"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Enter API Key"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection("Users")
                      .doc(uid)
                      .set({field: controller.text}, SetOptions(merge: true));
                  setState(() {
                    executorAccess[name] = true;
                  });
                  Navigator.pop(context);
                } catch (e) {
                  debugPrint("Error saving API key: $e");
                }
              },
              child: Text("Save"),
              ),
            ],
          );
        },
      );
    }
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
            details: "",
            isActive: executorAccess["IBM Hanoi"] ?? false,
            onTap: () => handleExecutorTap("IBM Hanoi"),
            // onTap: () => debugPrint("${executorAccess["IBM Hanoi"]}"), // not used for now
          ),
          ExecutorCard(
            name: "IonQ Aria",
            subtitle: "25 qubits • Trapped-ion system",
            details: "",
            isActive: executorAccess["IonQ Aria"] ?? false,
            onTap: () => handleExecutorTap("IonQ Aria"),
          ),
        ],
      ),
    );
  }
}

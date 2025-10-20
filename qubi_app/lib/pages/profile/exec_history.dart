import 'package:flutter/material.dart';

class ExecHistoryPage extends StatelessWidget {
  const ExecHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Execution History')),
      body: const Center(
        child: Text('Your execution history will appear here.'),
      ),
    );
  }
}

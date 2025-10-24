import 'package:flutter/material.dart';

class DefaultSettingsPage extends StatelessWidget {
  const DefaultSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Settings')),
      body: const Center(
        child: Text('Adjust your default Qubi settings here.'),
      ),
    );
  }
}

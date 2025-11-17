import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/executor_config.dart';
import '../../../user_bloc/stored_user_info.dart';

class ExecutorSetupPage extends StatefulWidget {
  const ExecutorSetupPage({super.key});

  @override
  State<ExecutorSetupPage> createState() => _ExecutorSetupPageState();
}

class _ExecutorSetupPageState extends State<ExecutorSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _ionqKeyController = TextEditingController();
  final _ibmKeyController = TextEditingController();
  final _defaultShotsController = TextEditingController(text: '1000');

  String _selectedExecutor = 'ionq_simulator';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscureIonq = true;
  bool _obscureIbm = true;

  final List<Map<String, String>> _availableExecutors = [
    {'value': 'ionq_simulator', 'label': 'IonQ Simulator'},
    {'value': 'ibm_simulator', 'label': 'IBM Simulator'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExecutorConfig();
  }

  @override
  void dispose() {
    _ionqKeyController.dispose();
    _ibmKeyController.dispose();
    _defaultShotsController.dispose();
    super.dispose();
  }

  Future<void> _loadExecutorConfig() async {
    try {
      final userId = await StoredUserInfo.getUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('settings')
          .doc('executor_config')
          .get();

      if (docSnapshot.exists) {
        final config = ExecutorConfig.fromJson(docSnapshot.data()!);
        setState(() {
          _ionqKeyController.text = config.ionqApiKey ?? '';
          _ibmKeyController.text = config.ibmApiKey ?? '';
          _selectedExecutor = config.defaultExecutor;
          _defaultShotsController.text = config.defaultShots.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading config: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveExecutorConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = await StoredUserInfo.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final config = ExecutorConfig(
        ionqApiKey: _ionqKeyController.text.trim().isEmpty
            ? null
            : _ionqKeyController.text.trim(),
        ibmApiKey: _ibmKeyController.text.trim().isEmpty
            ? null
            : _ibmKeyController.text.trim(),
        defaultExecutor: _selectedExecutor,
        defaultShots: int.parse(_defaultShotsController.text),
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('settings')
          .doc('executor_config')
          .set(config.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Executor configuration saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving config: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executor Setup'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Configure Your Quantum Executors',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your API keys for different quantum computing providers. If you don\'t provide a key, the default system keys will be used.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // IonQ API Key
                    _buildSectionTitle('IonQ API Key'),
                    TextFormField(
                      controller: _ionqKeyController,
                      obscureText: _obscureIonq,
                      decoration: InputDecoration(
                        hintText: 'Enter your IonQ API key (optional)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureIonq ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscureIonq = !_obscureIonq);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // IBM API Key
                    _buildSectionTitle('IBM Quantum API Key'),
                    TextFormField(
                      controller: _ibmKeyController,
                      obscureText: _obscureIbm,
                      decoration: InputDecoration(
                        hintText: 'Enter your IBM Quantum API key (optional)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureIbm ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscureIbm = !_obscureIbm);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Divider(),
                    const SizedBox(height: 16),

                    // Default Executor
                    _buildSectionTitle('Default Quantum Computer'),
                    DropdownButtonFormField<String>(
                      value: _selectedExecutor,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _availableExecutors.map((executor) {
                        return DropdownMenuItem<String>(
                          value: executor['value'],
                          child: Text(executor['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedExecutor = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Default Shots
                    _buildSectionTitle('Default Number of Shots (Max 1000)'),
                    TextFormField(
                      controller: _defaultShotsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g., 1000',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of shots';
                        }
                        final shots = int.tryParse(value);
                        if (shots == null || shots <= 0 || shots > 1000) {
                          return 'Please enter a valid number of shots';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveExecutorConfig,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Configuration',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

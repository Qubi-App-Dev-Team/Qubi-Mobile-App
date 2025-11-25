// lib/pages/profile/models/run_result.dart

class RunResult {
  final String status; // "waiting for quantum computer", "completed", etc.
  final String? circuitId;
  final String? runRequestId;
  final String quantumComputer;
  final Map<String, int> histogramCounts;
  final Map<String, double> histogramProbabilities;
  final double elapsedTime;
  final int shots;
  final String? userId;
  final DateTime? createdAt;
  final bool success;

  const RunResult({
    required this.status,
    this.circuitId,
    this.runRequestId,
    required this.quantumComputer,
    required this.histogramCounts,
    required this.histogramProbabilities,
    required this.elapsedTime,
    required this.shots,
    this.userId,
    this.createdAt,
    this.success = false,
  });

  factory RunResult.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? '';

    if (status != 'completed' || json['run_result'] == null) {
      return RunResult(
        status: status,
        quantumComputer: json['quantum_computer'] ?? '',
        histogramCounts: const {},
        histogramProbabilities: const {},
        elapsedTime: 0.0,
        shots: json['shots'] ?? 0,
      );
    }

    final result = json['run_result'] as Map<String, dynamic>;

    final countsMap = <String, int>{};
    if (result['histogram_counts'] != null) {
      (result['histogram_counts'] as Map<String, dynamic>).forEach((k, v) {
        countsMap[k] = (v as num).toInt();
      });
    }

    final probsMap = <String, double>{};
    if (result['histogram_probabilities'] != null) {
      (result['histogram_probabilities'] as Map<String, dynamic>)
          .forEach((k, v) {
        probsMap[k] = (v as num).toDouble();
      });
    }

    return RunResult(
      status: status,
      circuitId: result['circuit_id'],
      runRequestId: result['run_request_id'] ?? '',
      quantumComputer: result['quantum_computer'] ?? '',
      histogramCounts: countsMap,
      histogramProbabilities: probsMap,
      elapsedTime: (result['elapsed_time_s'] ?? 0).toDouble(),
      shots: result['shots'] ?? 0,
      userId: result['user_id'],
      createdAt: result['created_at'] != null
          ? DateTime.tryParse(result['created_at'])
          : null,
      success: result['success'] ?? false,
    );
  }

  bool get isPending => status.toLowerCase().contains('waiting');
  bool get isComplete => status.toLowerCase() == 'completed';
  bool get isInvalid => status.toLowerCase().contains('does not exist');

  String get hardwareDisplayName {
    final id = quantumComputer.toLowerCase();
    if (id.contains('ibm')) return 'IBM';
    if (id.contains('ionq')) return 'IonQ';
    return 'Simulated';
  }
}

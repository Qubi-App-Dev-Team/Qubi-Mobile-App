class Execution {
  final bool success;
  final String circuitId;
  final String quantumComputer;
  final Map<String, int> histogramCounts;
  final Map<String, double> histogramProbabilities;
  final double time;
  final int shots;
  final String createdAt;
  final String status;
  final String? userId; // optional since backend provides it

  const Execution({
    required this.success,
    required this.circuitId,
    required this.quantumComputer,
    required this.histogramCounts,
    required this.histogramProbabilities,
    required this.time,
    required this.shots,
    required this.createdAt,
    required this.status,
    this.userId,
  });

  /// Factory for converting backend JSON → Execution instance
  factory Execution.fromJson(Map<String, dynamic> json) {
    // Backend wraps execution data inside `run_result`
    final result = json['run_result'] as Map<String, dynamic>;

    // Backend sends flat maps, not lists
    final countsMap = Map<String, int>.from(
      result['histogram_counts'] ?? <String, int>{},
    );
    final probsMap = Map<String, double>.from(
      result['histogram_probabilities'] ?? <String, double>{},
    );

    return Execution(
      status: json['status'] ?? '',
      success: result['success'] ?? false,
      circuitId: result['circuit_id'] ?? '',
      quantumComputer: result['quantum_computer'] ?? '',
      histogramCounts: countsMap,
      histogramProbabilities: probsMap,
      time: (result['elapsed_time_s'] ?? 0).toDouble(),
      shots: result['shots'] ?? 0,
      createdAt: result['created_at'] ?? '',
      userId: result['user_id'],
    );
  }

  /// Convert Execution instance → JSON (if you need to send it back)
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'run_result': {
        'success': success,
        'circuit_id': circuitId,
        'quantum_computer': quantumComputer,
        'histogram_counts': histogramCounts,
        'histogram_probabilities': histogramProbabilities,
        'elapsed_time_s': time,
        'shots': shots,
        'created_at': createdAt,
        'user_id': userId,
      },
    };
  }

  String get hardwareDisplayName {
    final id = quantumComputer.toLowerCase();
    if (id.contains('ibm')) return 'IBM';
    if (id.contains('ionq')) return 'IonQ';
    return 'Simulated';
  }
}

class RunHistory {
  /// The ID of the user who executed the circuit.
  final String userId;

  /// The circuit ID that was executed.
  final String circuitId;

  /// The backend hardware used (e.g., "ionq_simulator", "ibm_q").
  final String quantumComputer;

  /// Number of shots for this run.
  final int shots;

  /// Whether the execution was successful.
  final bool success;

  /// How long the job took (seconds).
  final double elapsedTime;

  /// Raw histogram counts (e.g., {"00": 492, "11": 508})
  final Map<String, int> histogramCounts;

  /// Normalized probabilities (e.g., {"00": 0.492, "11": 0.508})
  final Map<String, double> histogramProbabilities;

  /// When this run was created.
  final DateTime createdAt;

  const RunHistory({
    required this.userId,
    required this.circuitId,
    required this.quantumComputer,
    required this.shots,
    required this.success,
    required this.elapsedTime,
    required this.histogramCounts,
    required this.histogramProbabilities,
    required this.createdAt,
  });

  factory RunHistory.fromJson(Map<String, dynamic> json) {
    final counts = <String, int>{};
    if (json['histogram_counts'] != null) {
      (json['histogram_counts'] as Map<String, dynamic>).forEach((k, v) {
        counts[k] = (v as num).toInt();
      });
    }

    final probs = <String, double>{};
    if (json['histogram_probabilities'] != null) {
      (json['histogram_probabilities'] as Map<String, dynamic>).forEach((k, v) {
        probs[k] = (v as num).toDouble();
      });
    }

    return RunHistory(
      userId: json['user_id'] ?? '',
      circuitId: json['circuit_id'] ?? '',
      quantumComputer: json['quantum_computer'] ?? '',
      shots: (json['shots'] ?? 0).toInt(),
      success: json['success'] ?? false,
      elapsedTime: (json['elapsed_time_s'] ?? 0).toDouble(),
      histogramCounts: counts,
      histogramProbabilities: probs,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  // -------------------------------------------
  // 🔍 Convenience getters for display
  // -------------------------------------------
  String get hardwareDisplayName {
    final id = quantumComputer.toLowerCase();
    if (id.contains('ibm')) return 'IBM';
    if (id.contains('ionq')) return 'IonQ';
    return 'Simulated';
  }

  bool get isSimulator => hardwareDisplayName == 'Simulated';
  String get badgeLabel => isSimulator ? 'Simulated' : 'Real';
}

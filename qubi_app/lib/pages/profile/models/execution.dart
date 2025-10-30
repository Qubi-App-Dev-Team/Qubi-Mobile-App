class Execution {
  final bool message;
  final String circuitId;
  final String runId;
  final String quantumComputer;
  final Map<String, int> histogramCounts;
  final Map<String, double> histogramProbabilities;
  final double time;
  final int shots;

  const Execution({
    required this.message,
    required this.circuitId,
    required this.runId,
    required this.quantumComputer,
    required this.histogramCounts,
    required this.histogramProbabilities,
    required this.time,
    required this.shots,
  });

  factory Execution.fromJson(Map<String, dynamic> json) {
    // The backend sends histogram_counts and histogram_probabilities as lists of maps:
    // [{"00": 490}, {"11": 510}], [{"00": 0.5}, {"11": 0.5}]
    final countsList = json['histogram_counts'] as List<dynamic>;
    final probsList = json['histogram_probabilities'] as List<dynamic>;

    final countsMap = <String, int>{};
    for (final entry in countsList) {
      countsMap.addAll(Map<String, int>.from(entry));
    }

    final probsMap = <String, double>{};
    for (final entry in probsList) {
      probsMap.addAll(Map<String, double>.from(entry));
    }

    return Execution(
      message: json['message'] ?? false,
      circuitId: json['circuit_id'] ?? '',
      runId: json['run_id'] ?? '',
      quantumComputer: json['quantum_computer'] ?? '',
      histogramCounts: countsMap,
      histogramProbabilities: probsMap,
      time: (json['time'] ?? 0).toDouble(),
      shots: json['shots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'circuit_id': circuitId,
      'run_id': runId,
      'quantum_computer': hardwareDisplayName,
      'histogram_counts': [
        for (var e in histogramCounts.entries) {e.key: e.value},
      ],
      'histogram_probabilities': [
        for (var e in histogramProbabilities.entries) {e.key: e.value},
      ],
      'time': time,
      'shots': shots,
    };
  }

  String get hardwareDisplayName {
    final id = quantumComputer.toLowerCase();
    if (id.contains('ibm')) return 'IBM';
    if (id.contains('ionq')) return 'IonQ';
    return 'Simulated';
  }
}

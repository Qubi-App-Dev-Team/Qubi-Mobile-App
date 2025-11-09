class ExecutionModel {
  final String? userId;
  final DateTime? createdAt;
  final bool? success;
  final int? shots;
  final Map<String, int>? histogramCounts;
  final Map<String, double>? histogramProbabilities;
  final String? circuitId;
  final double? elapsedTimeS;
  final String? quantumComputer;

  const ExecutionModel({
    this.userId,
    this.createdAt,
    this.success,
    this.shots,
    this.histogramCounts,
    this.histogramProbabilities,
    this.circuitId,
    this.elapsedTimeS,
    this.quantumComputer,
  });

  factory ExecutionModel.fromJson(Map<String, dynamic> json) {
    // Handle both possible data formats (list of maps OR flat map)
    Map<String, int>? counts;
    Map<String, double>? probs;

    final countsField = json['histogram_counts'];
    final probsField = json['histogram_probabilities'];

    if (countsField is List) {
      counts = {};
      for (final entry in countsField) {
        counts.addAll(Map<String, int>.from(entry));
      }
    } else if (countsField is Map) {
      counts = Map<String, int>.from(countsField);
    }

    if (probsField is List) {
      probs = {};
      for (final entry in probsField) {
        probs.addAll(Map<String, double>.from(entry));
      }
    } else if (probsField is Map) {
      probs = Map<String, double>.from(probsField);
    }

    return ExecutionModel(
      userId: json['user_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      success: json['success'],
      shots: json['shots'],
      histogramCounts: counts,
      histogramProbabilities: probs,
      circuitId: json['circuit_id'],
      elapsedTimeS: (json['elapsed_time_s'] ?? json['time'] ?? 0).toDouble(),
      quantumComputer: json['quantum_computer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'success': success,
      'shots': shots,
      'histogram_counts': [
        if (histogramCounts != null)
          for (var e in histogramCounts!.entries) {e.key: e.value},
      ],
      'histogram_probabilities': [
        if (histogramProbabilities != null)
          for (var e in histogramProbabilities!.entries) {e.key: e.value},
      ],
      'circuit_id': circuitId,
      'elapsed_time_s': elapsedTimeS,
      'quantum_computer': quantumComputer,
    };
  }

  /// Friendly display name for the hardware
  String get hardwareDisplayName {
    final id = (quantumComputer ?? '').toLowerCase();
    if (id.contains('ibm')) return 'IBM';
    if (id.contains('ionq')) return 'IonQ';
    return 'Simulated';
  }
}

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
  final String? errorMessage; // NEW

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
    this.errorMessage, // NEW
  });

  
  factory ExecutionModel.fromJson(Map<String, dynamic> json) {
    Map<String, int>? counts;
    Map<String, double>? probs;

    final bool? success = json['success'];

    // ---- HISTOGRAM COUNTS ----
    // New schema
    if (json['counts'] is Map) {
      counts = Map<String, int>.from(json['counts']);
    }
    // Old schema
    else if (json['histogram_counts'] is Map) {
      counts = Map<String, int>.from(json['histogram_counts']);
    }

    // ---- HISTOGRAM PROBABILITIES ----
    // New schema
    if (json['probabilities'] is Map) {
      probs = Map<String, double>.from(json['probabilities']);
    }
    // Old schema
    else if (json['histogram_probabilities'] is Map) {
      probs = Map<String, double>.from(json['histogram_probabilities']);
    }

    // ---- FAILURE CASE: CLEAR HISTOGRAMS ----
    if (success == false) {
      counts = {};
      probs = {};
    }

    // ---- ELAPSED TIME ----
    final elapsed = json['elapsed_time'] ??
                    json['elapsed_time_s'] ??
                    json['time'] ??
                    0;

    // ---- QUANTUM COMPUTER NAME ----
    final backendName = json['backend_name'] ?? json['quantum_computer'];

    return ExecutionModel(
      userId: json['user_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      success: success,
      shots: json['shots'],
      histogramCounts: counts,
      histogramProbabilities: probs,
      circuitId: json['circuit_id'],
      elapsedTimeS: (elapsed as num).toDouble(),
      quantumComputer: backendName,
      errorMessage: json['error_message'], // safe fallback
    );
  }

  /*
  factory ExecutionModel.fromJson(Map<String, dynamic> json) {
    // Handle both possible data formats (list of maps OR flat map)
    Map<String, int>? counts;
    Map<String, double>? probs;

    final countsField = json['histogram_counts'];
    final probsField = json['histogram_probabilities'];
    final bool? success = json['success'];

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

    // If success is explicitly false, force histograms to be empty
    if (success == false) {
      counts = {};
      probs = {};
    }

    return ExecutionModel(
      userId: json['user_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      success: success,
      shots: json['shots'],
      histogramCounts: counts,
      histogramProbabilities: probs,
      circuitId: json['circuit_id'],
      elapsedTimeS: (json['elapsed_time_s'] ?? json['time'] ?? 0).toDouble(),
      quantumComputer: json['quantum_computer'],
      errorMessage: json['error_message'], // NEW
    );
  }*/
  

  Map<String, dynamic> toJson() {
    final bool? isSuccess = success;

    // If success is false, serialize empty histograms
    final Map<String, int>? countsToWrite =
        (isSuccess == false) ? {} : histogramCounts;
    final Map<String, double>? probsToWrite =
        (isSuccess == false) ? {} : histogramProbabilities;

    return {
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'success': success,
      'shots': shots,
      'histogram_counts': [
        if (countsToWrite != null)
          for (var e in countsToWrite.entries) {e.key: e.value},
      ],
      'histogram_probabilities': [
        if (probsToWrite != null)
          for (var e in probsToWrite.entries) {e.key: e.value},
      ],
      'circuit_id': circuitId,
      'elapsed_time_s': elapsedTimeS,
      'quantum_computer': quantumComputer,
      'error_message': errorMessage, // NEW
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

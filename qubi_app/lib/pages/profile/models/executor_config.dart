class ExecutorConfig {
  final String? ionqApiKey;
  final String? ibmApiKey;
  final String defaultExecutor;
  final int defaultShots;

  ExecutorConfig({
    this.ionqApiKey,
    this.ibmApiKey,
    this.defaultExecutor = 'ionq_simulator',
    this.defaultShots = 1000,
  });

  factory ExecutorConfig.fromJson(Map<String, dynamic> json) {
    return ExecutorConfig(
      ionqApiKey: json['ionq_api_key'] as String?,
      ibmApiKey: json['ibm_api_key'] as String?,
      defaultExecutor: json['default_executor'] as String? ?? 'ionq_simulator',
      defaultShots: json['default_shots'] as int? ?? 1000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ionq_api_key': ionqApiKey,
      'ibm_api_key': ibmApiKey,
      'default_executor': defaultExecutor,
      'default_shots': defaultShots,
    };
  }

  ExecutorConfig copyWith({
    String? ionqApiKey,
    String? ibmApiKey,
    String? defaultExecutor,
    int? defaultShots,
  }) {
    return ExecutorConfig(
      ionqApiKey: ionqApiKey ?? this.ionqApiKey,
      ibmApiKey: ibmApiKey ?? this.ibmApiKey,
      defaultExecutor: defaultExecutor ?? this.defaultExecutor,
      defaultShots: defaultShots ?? this.defaultShots,
    );
  }

  bool get hasIonqKey => ionqApiKey != null && ionqApiKey!.isNotEmpty;
  bool get hasIbmKey => ibmApiKey != null && ibmApiKey!.isNotEmpty;
}

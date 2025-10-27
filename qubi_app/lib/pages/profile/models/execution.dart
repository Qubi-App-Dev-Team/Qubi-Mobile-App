class Execution {
  final String name;
  final String status;
  final String time;
  final String hardware;
  final String totalTime;
  final String pendingTime;
  final String executionTime;
  final String perShot;
  final String circuitDepth;
  final String resultCount;
  final Map<String, int> results;

  Execution({
    required this.name,
    required this.status,
    required this.time,
    required this.hardware,
    required this.totalTime,
    required this.pendingTime,
    required this.executionTime,
    required this.perShot,
    required this.circuitDepth,
    required this.resultCount,
    required this.results,
  });

  factory Execution.fromJson(Map<String, dynamic> json) {
    return Execution(
      name: json['name'],
      status: json['status'],
      time: json['time'],
      hardware: json['hardware'],
      totalTime: json['totalTime'],
      pendingTime: json['pendingTime'],
      executionTime: json['executionTime'],
      perShot: json['perShot'],
      circuitDepth: json['circuitDepth'],
      resultCount: json['resultCount'],
      results: {
        for (var entry in (json['results'] as List))
          ...entry.map((k, v) => MapEntry(k, v as int)),
      },
    );
  }
}

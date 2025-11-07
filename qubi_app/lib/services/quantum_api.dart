import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qubi_app/pages/profile/models/execution.dart';

class QuantumAPI {
  static const baseUrl = 'https://your.backend.url';

  static Future<String?> makeRequest(Map<String, dynamic> circuitJson) async {
    try {
      final url = Uri.parse('$baseUrl/make_request');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(circuitJson),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['circuit_id'] as String?;
      } else {
        print(
          'Failed to make request: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error making request: $e');
      return null;
    }
  }

  static Future<Execution?> fetchResults(String circuitId) async {
    try {
      final url = Uri.parse('$baseUrl/fetch_results?circuit_id=$circuitId');
      const timeoutSeconds = 30;
      final startTime = DateTime.now();

      while (DateTime.now().difference(startTime).inSeconds < timeoutSeconds) {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return Execution.fromJson(data);
          } else {
            print('Invalid response structure.');
            return null;
          }
        } else if (response.statusCode == 202) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else if (response.statusCode == 404) {
          print('Circuit not found.');
          return null;
        } else {
          print('Unexpected: ${response.statusCode} - ${response.body}');
          return null;
        }
      }

      print('Timeout waiting for circuit results.');
      return null;
    } catch (e) {
      print('Error fetching results: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qubi_app/pages/profile/models/execution.dart';
import 'package:qubi_app/pages/profile/models/run_history.dart';
import 'package:qubi_app/pages/profile/models/execution_model.dart';
import 'package:qubi_app/user_bloc/stored_user_info.dart'; // for StoredUserInfo.userID

/// Global debug flag (replace this with your own variable if declared elsewhere)
const bool debug = true;

/// Centralized client for calling the Qubi backend API.
class ApiClient {
  // Load your base URL from .env, fallback to localhost
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  // =======================================================
  // 1️⃣  MAKE REQUEST
  // =======================================================
  /// Calls the backend `/make_request` endpoint.
  /// Returns the generated `run_request_id` from the backend.
  static Future<String> makeRequest({
    required String userId,
    required Map<String, dynamic> circuit,
    String quantumComputer = 'ionq_simulator',
    int shots = 1000,
  }) async {
    final url = Uri.parse('$_baseUrl/make_request');

    final body = jsonEncode({
      'user_id': userId,
      'circuit': circuit,
      'quantum_computer': quantumComputer,
      'shots': shots,
    });

    if (debug) {
      print('[ApiClient] → POST $url');
      print('Request body: $body');
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final runRequestId = decoded['run_request_id'] as String?;
      if (runRequestId == null) {
        throw Exception('No run_request_id returned from /make_request.');
      }
      if (debug) print('[ApiClient] ✅ run_request_id: $runRequestId');
      return runRequestId;
    } else {
      if (debug) {
        print('[ApiClient] ❌ makeRequest failed: ${response.statusCode}');
        print(response.body);
      }
      throw Exception(
          'Failed to call /make_request. Status: ${response.statusCode}');
    }
  }

  // =======================================================
  // 2️⃣  FETCH RESULTS
  // =======================================================
  /// Polls `/fetch_results` for the given run_request_id.
  /// Handles 202 (waiting), 200 (completed), and 404 (not found).
  static Future<Execution?> fetchResults({
    required String runRequestId,
  }) async {
    final url =
        Uri.parse('$_baseUrl/fetch_results?run_request_id=$runRequestId');

    if (debug) print('[ApiClient] → GET $url');

    final response = await http.get(url);

    // -------------------------
    // Case 1: 202 - Still waiting
    // -------------------------
    if (response.statusCode == 202) {
      final decoded = jsonDecode(response.body);
      if (debug) {
        print('[ApiClient] ⏳ Still waiting on quantum computer...');
        print('Details: $decoded');
      }
      return null;
    }

    // -------------------------
    // Case 2: 200 - Results ready
    // -------------------------
    else if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final runResult = decoded['run_result'];

      if (runResult == null) {
        throw Exception('Missing "run_result" field in /fetch_results response.');
      }

      if (debug) print('[ApiClient] ✅ Results ready from quantum computer.');

      return Execution(
        message: true,
        circuitId: runResult['circuit_id'] ?? 'unknown',
        runId: runRequestId,
        quantumComputer: runResult['quantum_computer'] ?? 'unknown',
        histogramCounts:
            Map<String, int>.from(runResult['histogram_counts'] ?? {}),
        histogramProbabilities:
            Map<String, double>.from(runResult['histogram_probabilities'] ?? {}),
        time: (runResult['elapsed_time_s'] ?? 0).toDouble(),
        shots: (runResult['shots'] ?? 0).toInt(),
      );
    }

    // -------------------------
    // Case 3: 404 - Request not found
    // -------------------------
    else if (response.statusCode == 404) {
      final decoded = jsonDecode(response.body);
      if (debug) print('[ApiClient] ❌ Request not found: ${decoded['status']}');
      throw Exception('Run request does not exist.');
    }

    // -------------------------
    // Any other unexpected response
    // -------------------------
    else {
      if (debug) {
        print('[ApiClient] ❌ Unexpected status: ${response.statusCode}');
        print(response.body);
      }
      throw Exception(
          'Unexpected response from /fetch_results: ${response.statusCode}');
    }
  }

  // =======================================================
  // 3️⃣  FETCH RUN HISTORY
  // =======================================================
  /// Calls `/fetch_run_history` to retrieve recent executions for a user.
  /// Returns a list of `Execution` objects.
  static Future<List<ExecutionModel>> fetchRunHistory({int limit = 10}) async {
    final userId = StoredUserInfo.userID;
    final url = Uri.parse('$_baseUrl/fetch_run_history?user_id=$userId&limit=$limit');

    final response = await http.get(url, headers: {'Content-Type': 'application/json'});


    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final historyList = decoded['history'] as List<dynamic>?;

      if (historyList == null) {
        throw Exception('Missing "history" field in response');
      }

      final runs =
          historyList.map((e) => ExecutionModel.fromJson(e)).toList();
      return runs;
    } else {
      throw Exception(
          'Failed to fetch run history. Status: ${response.statusCode}');
    }
  }
}

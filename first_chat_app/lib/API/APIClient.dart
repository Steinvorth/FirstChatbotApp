import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

/// Centralized HTTP client for all API calls.
/// All endpoints and the base URL live here — one place to configure.
class APIClient {
  APIClient._();

  /// Base URL resolves to the correct host:
  /// - Android emulator uses 10.0.2.2 to reach the host machine's localhost
  /// - iOS simulator and desktop use regular localhost
  static final String baseUrl = _ResolveBaseUrl();

  static String _ResolveBaseUrl() {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {
      // Platform not available (web) — fall through to default
    }
    return 'http://localhost:8000';
  }

  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ─── GET ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> Get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri, headers: _defaultHeaders);
    return _HandleResponse(response);
  }

  // ─── POST ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> Post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _HandleResponse(response);
  }

  // ─── DELETE ────────────────────────────────────────────
  static Future<Map<String, dynamic>> Delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: _defaultHeaders);
    return _HandleResponse(response);
  }

  // ─── Response handler ─────────────────────────────────
  static Map<String, dynamic> _HandleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    return {
      'error': true,
      'statusCode': response.statusCode,
      'message': response.body,
    };
  }
}

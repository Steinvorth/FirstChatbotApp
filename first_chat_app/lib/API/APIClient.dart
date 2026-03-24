import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

/// A single Server-Sent Event parsed from the stream.
class SSEEvent {
  final String event;
  final String data;
  const SSEEvent({required this.event, required this.data});
}

/// Centralized HTTP client for all API calls.
/// All endpoints and the base URL live here — one place to configure.
class APIClient {
  APIClient._();

  static final String baseUrl = _ResolveBaseUrl();

  static String _ResolveBaseUrl() {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
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

  // ─── POST with SSE Streaming ───────────────────────────
  // Returns a Stream of SSEEvent objects as they arrive.
  // The API sends: event: token\ndata: "word"\n\n
  // We parse each event and yield it to the caller.
  static Stream<SSEEvent> PostStream(
    String path, {
    Map<String, dynamic>? body,
  }) async* {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.Request('POST', uri);
    request.headers.addAll(_defaultHeaders);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);

      // Read the byte stream, decode to UTF-8, and split by lines.
      // SSE format: "event: <type>\ndata: <value>\n\n"
      String buffer = '';
      String? currentEvent;
      String? currentData;

      await for (final chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        buffer += chunk;

        // Process complete SSE messages (separated by double newline)
        while (buffer.contains('\n\n')) {
          final messageEnd = buffer.indexOf('\n\n');
          final message = buffer.substring(0, messageEnd);
          buffer = buffer.substring(messageEnd + 2);

          // Parse the SSE message lines
          currentEvent = null;
          currentData = null;

          for (final line in message.split('\n')) {
            if (line.startsWith('event: ')) {
              currentEvent = line.substring(7);
            } else if (line.startsWith('data: ')) {
              currentData = line.substring(6);
            }
          }

          if (currentEvent != null) {
            yield SSEEvent(event: currentEvent, data: currentData ?? '');
          }
        }
      }
    } finally {
      client.close();
    }
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

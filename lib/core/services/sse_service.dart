import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/core/utils/helpers.dart';

/// ===================== SSE SERVICE =====================
/// Implements a lightweight Server-Sent Events (SSE) client using
/// dart:io HttpClient — no extra packages required.
///
/// Usage:
///   final svc = SseService();
///   final sub = svc.connect(raceId).listen((event) { ... });
///   // when done:
///   svc.close();
///
/// Events emitted on the returned stream:
///   { "type": "connected",      "data": { ... } }
///   { "type": "race:snapshot",  "data": { ... } }
///   { "type": "race:update",    "data": { ... } }
///
class SseService {
  HttpClient? _httpClient;
  StreamSubscription? _lineSub;
  bool _closed = false;

  // Internal broadcast stream controller
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Expose events as a broadcast stream.
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  // ──────────────────────────────────────────────────────────────────────────
  // CONNECT
  // Opens a long-lived GET request to /race/:raceId/stream and starts
  // parsing incoming SSE frames from the chunked response body.
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> connect(String raceId) async {
    _closed = false;

    try {
      final token = await StorageService.getString(StorageConstants.bearerToken);
      if (token.isEmpty) {
        Helpers.warning('[SSE] No auth token — skipping race stream connection');
        return;
      }

      // Build the full URL: strip trailing slash from baseUrl, then append path
      final baseUrl = ApiConstants.baseUrl.endsWith('/')
          ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
          : ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl/race/$raceId/stream');

      Helpers.debug('[SSE] Connecting to: $uri');

      _httpClient = HttpClient();
      _httpClient!.connectionTimeout = const Duration(seconds: 30);

      final request = await _httpClient!.getUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');

      final response = await request.close();

      if (response.statusCode != 200) {
        Helpers.error('[SSE] Server returned ${response.statusCode} for race stream');
        return;
      }

      Helpers.info('[SSE] Connected to race stream: $raceId');

      // ── SSE Frame Parser ────────────────────────────────────────────────
      // The SSE protocol sends lines like:
      //   event: race:update
      //   data: {"raceId":"...", ...}
      //                           ← blank line = end of event frame
      //   : heartbeat             ← comment, ignore
      String currentEvent = '';
      String currentData = '';

      _lineSub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (_closed) return;

          if (line.startsWith(':')) {
            // Comment / heartbeat — ignore
            return;
          }

          if (line.isEmpty) {
            // Blank line = end of event frame → emit
            if (currentData.isNotEmpty) {
              _emitEvent(currentEvent, currentData);
            }
            currentEvent = '';
            currentData = '';
            return;
          }

          if (line.startsWith('event:')) {
            currentEvent = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            currentData = line.substring(5).trim();
          }
        },
        onError: (error) {
          Helpers.error('[SSE] Stream error: $error');
          if (!_controller.isClosed) {
            _controller.addError(error);
          }
        },
        onDone: () {
          Helpers.info('[SSE] Stream closed by server for race: $raceId');
        },
        cancelOnError: false,
      );
    } catch (e) {
      Helpers.error('[SSE] Connection error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EMIT EVENT
  // Parses the raw JSON data string and pushes a typed event map.
  // ──────────────────────────────────────────────────────────────────────────
  void _emitEvent(String eventType, String rawData) {
    try {
      final decoded = jsonDecode(rawData);
      if (decoded is Map) {
        _controller.add({
          'type': eventType,
          'data': Map<String, dynamic>.from(decoded),
        });
        Helpers.debug('[SSE] Event received: $eventType');
      }
    } catch (e) {
      Helpers.warning('[SSE] Failed to parse event data: $e  raw=$rawData');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CLOSE
  // Tears down the connection gracefully.
  // ──────────────────────────────────────────────────────────────────────────
  void close() {
    _closed = true;
    _lineSub?.cancel();
    _httpClient?.close(force: true);
    _httpClient = null;
    _lineSub = null;
    Helpers.debug('[SSE] Connection closed');
  }

  void dispose() {
    close();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ===================== APP LOGGER =====================
/// Centralized logging utility for API requests, responses, and errors.
/// Only logs in debug mode to avoid leaking sensitive data in production.

class AppLogger {
  AppLogger._();

  static const String _divider = '══════════════════════════════════════';

  /// Log outgoing API request
  static void request(RequestOptions options) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ➡️➡️➡️➡️ REQUEST $_divider ➡️➡️➡️➡️');
    debugPrint('│ ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${_sanitizeHeaders(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      _printData('Query', options.queryParameters);
    }
    if (options.data != null) {
      _printData('Body', options.data);
    }
    debugPrint('└ ➡️➡️➡️➡️ REQUEST $_divider ➡️➡️➡️➡️');
    debugPrint('');
  }

  /// Log incoming API response
  static void response(Response response) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ✅✅✅✅ RESPONSE $_divider ✅✅✅✅');
    debugPrint(
      '│ [ ${response.requestOptions.method} ${response.statusCode}] ${response.requestOptions.uri}',
    );
    _printData('Data', response.data);
    debugPrint('└ ✅✅✅✅ RESPONSE $_divider ✅✅✅✅');
    debugPrint('');
  }

  /// Log API error
  static void error(DioException e) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ❌❌❌❌ ERROR $_divider ❌❌❌❌ ');
    debugPrint('│ ${e.type.name}: ${e.message}');
    debugPrint('│  ${e.requestOptions.method} : ${e.requestOptions.uri}');
    if (e.response != null) {
      debugPrint('│ Status: ${e.response?.statusCode}');
      _printData('Data', e.response?.data);
    }
    debugPrint('└ ❌❌❌❌ ERROR $_divider ❌❌❌❌ ');
    debugPrint('');
  }

  // ──────────────────── PRIVATE HELPERS ────────────────────

  /// Pretty print JSON data (Maps, Lists, or JSON Strings)
  static String _prettyJson(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is String) {
        final decoded = json.decode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (_) {
      return data.toString();
    }
  }

  /// Print data with multi-line prefix alignment and chunking to prevent logcat truncation
  static void _printData(String label, dynamic data) {
    final pretty = _prettyJson(data);
    final lines = pretty.split('\n');
    if (lines.length == 1) {
      _logWrapped('│ $label: ${lines.first}');
    } else {
      _logWrapped('│ $label:');
      for (final line in lines) {
        _logWrapped('│   $line');
      }
    }
  }

  /// Print log message in chunks of 800 characters to prevent Flutter/OS log truncation
  static void _logWrapped(String text) {
    if (text.length <= 800) {
      debugPrint(text);
    } else {
      int start = 0;
      while (start < text.length) {
        int end = start + 800;
        if (end > text.length) end = text.length;
        debugPrint(text.substring(start, end));
        start = end;
      }
    }
  }

  /// Remove Authorization header value for safe logging
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***';
    }
    return sanitized;
  }
}

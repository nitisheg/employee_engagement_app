import 'package:flutter/foundation.dart';

/// Centralized logger for the app.
/// All output is suppressed in release builds (kDebugMode guard).
///
/// Usage:
///   AppLogger.info('AuthProvider', 'User logged in');
///   AppLogger.error('ApiService', 'Login failed', e, stackTrace);
class AppLogger {
  AppLogger._();

  // ── Public API ────────────────────────────────────────────────────────────

  /// Fine-grained debug information.
  static void debug(String tag, String message) {
    _log('🔍 DEBUG', tag, message);
  }

  /// General informational messages about normal app flow.
  static void info(String tag, String message) {
    _log('ℹ️  INFO ', tag, message);
  }

  /// Something unexpected but recoverable.
  static void warning(String tag, String message) {
    _log('⚠️  WARN ', tag, message);
  }

  /// Unrecoverable errors; optionally include the thrown object and stack.
  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log('❌ ERROR', tag, message);
    if (error != null) _raw('       ↳ $error');
    if (stackTrace != null) _raw('       ↳ $stackTrace');
  }

  /// Network request / response events.
  static void network(String tag, String message) {
    _log('🌐  NET  ', tag, message);
  }

  /// Successful completion of an operation.
  static void success(String tag, String message) {
    _log('✅  OK  ', tag, message);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static void _log(String level, String tag, String message) {
    if (!kDebugMode) return;
    final time = _timestamp();
    debugPrint('[$time][$level][$tag] $message');
  }

  static void _raw(String line) {
    if (!kDebugMode) return;
    debugPrint(line);
  }

  static String _timestamp() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

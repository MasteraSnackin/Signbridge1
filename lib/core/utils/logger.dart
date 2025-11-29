import 'package:flutter/foundation.dart';

/// Simple logger utility for the application
class Logger {
  final String? _tag;
  
  /// Create a logger with an optional tag
  Logger([this._tag]);
  
  /// Log levels
  static const String _debug = 'DEBUG';
  static const String _info = 'INFO';
  static const String _warning = 'WARNING';
  static const String _error = 'ERROR';
  
  /// Enable/disable logging
  static bool enabled = kDebugMode;
  
  /// Instance methods (for tagged loggers)
  void debug(String message) {
    Logger.debug(message, _tag);
  }
  
  void info(String message) {
    Logger.info(message, _tag);
  }
  
  void warning(String message) {
    Logger.warning(message, _tag);
  }
  
  void error(dynamic error, [StackTrace? stackTrace]) {
    Logger.error(error, stackTrace, _tag);
  }
  
  /// Static methods (for direct use)
  static void debug(String message, [String? tag]) {
    if (!enabled) return;
    _log(_debug, message, tag);
  }
  
  static void info(String message, [String? tag]) {
    if (!enabled) return;
    _log(_info, message, tag);
  }
  
  static void warning(String message, [String? tag]) {
    if (!enabled) return;
    _log(_warning, message, tag);
  }
  
  static void error(dynamic error, [StackTrace? stackTrace, String? tag]) {
    if (!enabled) return;
    _log(_error, error.toString(), tag);
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  /// Internal log method
  static void _log(String level, String message, String? tag) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag] ' : '';
    debugPrint('[$timestamp] [$level] $tagStr$message');
  }
  
  /// Log performance metric
  static void performance(String operation, Duration duration, [String? tag]) {
    if (!enabled) return;
    final ms = duration.inMilliseconds;
    info('$operation took ${ms}ms', tag ?? 'PERFORMANCE');
  }
}
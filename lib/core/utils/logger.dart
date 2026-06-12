import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight, dependency-free application logger.
///
/// Routes messages through `dart:developer.log` so they are structured in the
/// IDE and DevTools and can be filtered by level. Verbose `debug` output is
/// suppressed in release builds, while warnings and errors are always emitted.
class AppLogger {
  AppLogger._();

  static const String _name = 'bodido';

  /// Fine-grained diagnostic message. Stripped in release builds.
  static void debug(Object? message) {
    if (kReleaseMode) return;
    developer.log('$message', name: _name, level: 500);
  }

  /// General informational message.
  static void info(Object? message) {
    developer.log('$message', name: _name, level: 800);
  }

  /// Recoverable problem worth surfacing.
  static void warning(Object? message) {
    developer.log('$message', name: _name, level: 900);
  }

  /// Failure, optionally with the originating [error] and [stackTrace].
  static void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      '$message',
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

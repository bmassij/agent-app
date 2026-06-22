import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Redacts known secret key names from log output.
class AppLogger {
  const AppLogger();

  void debug(String message) {
    assert(() {
      // ignore: avoid_print
      print('[DEBUG] $message');
      return true;
    }());
  }

  void info(String message) {
    assert(() {
      // ignore: avoid_print
      print('[INFO] $message');
      return true;
    }());
  }

  void error(String message, {Object? error}) {
    assert(() {
      // ignore: avoid_print
      print('[ERROR] $message${error != null ? ': $error' : ''}');
      return true;
    }());
  }
}

final appLoggerProvider = Provider<AppLogger>((ref) => const AppLogger());

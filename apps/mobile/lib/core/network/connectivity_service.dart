import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/logging/app_logger.dart';

/// Network reachability (Sprint 2 — used by auth error messaging).
class ConnectivityService {
  ConnectivityService(this._logger);

  final AppLogger _logger;

  /// Always online in Sprint 2 stub; Sprint 6 adds connectivity_plus stream.
  Stream<bool> get isOnline => Stream.value(true);

  Future<bool> checkOnline() async {
    _logger.debug('connectivity check (stub: online)');
    return true;
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(ref.watch(appLoggerProvider));
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).isOnline;
});

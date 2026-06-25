import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/logging/app_logger.dart';

/// Network reachability via [connectivity_plus].
class ConnectivityService {
  ConnectivityService(this._connectivity, this._logger);

  final Connectivity _connectivity;
  final AppLogger _logger;

  Stream<bool> get isOnline =>
      _connectivity.onConnectivityChanged.asyncMap((_) => checkOnline());

  Future<bool> checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    final online = results.any(_isConnectedResult);
    _logger.debug('connectivity: $results → online=$online');
    return online;
  }

  bool _isConnectedResult(ConnectivityResult result) {
    return switch (result) {
      ConnectivityResult.mobile ||
      ConnectivityResult.wifi ||
      ConnectivityResult.ethernet ||
      ConnectivityResult.vpn ||
      ConnectivityResult.other ||
      ConnectivityResult.bluetooth ||
      ConnectivityResult.satellite =>
        true,
      ConnectivityResult.none => false,
    };
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(
    Connectivity(),
    ref.watch(appLoggerProvider),
  );
});

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.checkOnline();
  yield* service.isOnline;
});

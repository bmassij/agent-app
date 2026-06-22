/// SSE stream connection state for reconnection backoff.
enum StreamConnectionState {
  connected,
  disconnected,
  reconnecting,
  expired,
}

/// Exponential backoff for SSE reconnection (1s → 30s max).
class ReconnectionManager {
  ReconnectionManager({
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.maxAttempts = 6,
  });

  final Duration initialDelay;
  final Duration maxDelay;
  final int maxAttempts;

  StreamConnectionState _state = StreamConnectionState.disconnected;
  int _attempt = 0;

  StreamConnectionState get state => _state;

  int get attempt => _attempt;

  void markConnected() {
    _state = StreamConnectionState.connected;
    _attempt = 0;
  }

  void markDisconnected() {
    if (_state != StreamConnectionState.expired) {
      _state = StreamConnectionState.disconnected;
    }
  }

  void markStreamExpired() {
    _state = StreamConnectionState.expired;
    _attempt = 0;
  }

  /// Returns delay before next reconnect, or null if should stop.
  Duration? nextDelay({bool streamExpired = false}) {
    if (streamExpired) {
      markStreamExpired();
      return null;
    }
    if (_state == StreamConnectionState.expired) {
      return null;
    }
    if (_attempt >= maxAttempts) {
      return null;
    }
    _state = StreamConnectionState.reconnecting;
    final multiplier = 1 << _attempt;
    _attempt++;
    final seconds = initialDelay.inSeconds * multiplier;
    final capped = seconds > maxDelay.inSeconds ? maxDelay.inSeconds : seconds;
    return Duration(seconds: capped);
  }

  void reset() {
    _state = StreamConnectionState.disconnected;
    _attempt = 0;
  }
}

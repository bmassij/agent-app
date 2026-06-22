import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:test/test.dart';

void main() {
  test('backoff increases exponentially until cap', () {
    final manager = ReconnectionManager();
    expect(manager.nextDelay(), const Duration(seconds: 1));
    expect(manager.nextDelay(), const Duration(seconds: 2));
    expect(manager.nextDelay(), const Duration(seconds: 4));
    expect(manager.nextDelay(), const Duration(seconds: 8));
    expect(manager.nextDelay(), const Duration(seconds: 16));
    expect(manager.nextDelay(), const Duration(seconds: 30));
    expect(manager.nextDelay(), isNull);
  });

  test('stops on stream expired', () {
    final manager = ReconnectionManager();
    expect(manager.nextDelay(streamExpired: true), isNull);
    expect(manager.state, StreamConnectionState.expired);
    expect(manager.nextDelay(), isNull);
  });

  test('markConnected resets attempt counter', () {
    final manager = ReconnectionManager();
    manager.nextDelay();
    manager.markConnected();
    expect(manager.attempt, 0);
    expect(manager.nextDelay(), const Duration(seconds: 1));
  });
}

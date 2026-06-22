import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:test/test.dart';

import 'package:cursor_api_agents/cursor_api_agents.dart';

void main() {
  test('mapCursorApiError maps all known errors', () {
    expect(
      mapCursorApiError(const CursorAuthError('bad')),
      isA<AgentUnauthorizedFailure>(),
    );
    expect(
      mapCursorApiError(const CursorNotFoundError()),
      isA<AgentNotFoundFailure>(),
    );
    expect(
      mapCursorApiError(const CursorAgentBusyError(retryAfterSeconds: 5)),
      isA<AgentBusyFailure>(),
    );
    expect(
      mapCursorApiError(
        CursorRateLimitError(
          resetAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      isA<AgentRateLimitedFailure>(),
    );
    expect(
      mapCursorApiError(const CursorContextTooLargeError()),
      isA<AgentContextTooLargeFailure>(),
    );
    expect(
      mapCursorApiError(const CursorNetworkError('offline')),
      isA<AgentNetworkFailure>(),
    );
    expect(
      mapCursorApiError(const CursorServerError(502, 'bad gateway')),
      isA<AgentUnknownFailure>(),
    );
    expect(
      mapCursorApiError(const CursorUnknownError('x')),
      isA<AgentUnknownFailure>(),
    );
  });
}

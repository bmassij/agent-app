import 'package:cursor_api_stream/src/models/sse_event.dart';

/// Tracks run stream progress for Sprint 4 persistence foundation.
class RunStreamTracker {
  RunStreamTracker({
    required this.agentId,
    required this.runId,
  });

  final String agentId;
  final String runId;

  String? lastEventId;
  int sequenceIndex = 0;
  bool isComplete = false;
  String? lastStatus;

  void record(SseEvent event) {
    lastEventId = event.id ?? lastEventId;
    sequenceIndex++;
    if (event is StatusEvent) {
      lastStatus = event.status;
    }
    if (event is DoneEvent || event is ErrorEvent) {
      isComplete = true;
    }
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'agentId': agentId,
      'runId': runId,
      'lastEventId': lastEventId,
      'sequenceIndex': sequenceIndex,
      'isComplete': isComplete,
      'lastStatus': lastStatus,
    };
  }
}

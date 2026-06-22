import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_api_agents/cursor_api_agents.dart' show AgentFailure;

import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

/// Chat history, streaming, and SSE persistence.
abstract interface class ChatRepository {
  Stream<List<ChatMessageModel>> watchMessagesForAgent(String agentId);

  Stream<List<ToolCallModel>> watchToolCallsForAgent(String agentId);

  Future<void> insertUserMessage({
    required String runId,
    required String content,
  });

  Stream<SseEvent> streamRun({
    required String agentId,
    required String runId,
    String? lastEventId,
  });

  Future<void> persistSseEvent({
    required String agentId,
    required String runId,
    required SseEvent event,
  });

  Future<Either<AgentFailure, Unit>> fetchUsageForRun({
    required String agentId,
    required String runId,
  });

  List<String> get rawSseLogLines;

  bool get hasLoggedLiveSse;
}

import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/agents/domain/agent_failure.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

/// Chat history, streaming, and task event persistence.
abstract interface class ChatRepository {
  Stream<List<ChatMessageModel>> watchMessagesForAgent(String agentId);

  Stream<List<ToolCallModel>> watchToolCallsForAgent(String agentId);

  Future<void> insertUserMessage({
    required String runId,
    required String content,
  });

  Stream<TaskStreamEvent> streamRun({
    required String agentId,
    required String runId,
    String? lastEventId,
  });

  Future<void> persistStreamEvent({
    required String agentId,
    required String runId,
    required TaskStreamEvent event,
  });

  Future<Either<AgentFailure, Unit>> fetchUsageForRun({
    required String agentId,
    required String runId,
  });

  List<String> get rawSseLogLines;

  bool get hasLoggedLiveSse;
}

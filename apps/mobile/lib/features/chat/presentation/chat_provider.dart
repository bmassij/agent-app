import 'dart:async';

import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, agentId) async* {
  final repo = await ref.watch(chatRepositoryProvider.future);
  yield* repo.watchMessagesForAgent(agentId);
});

final toolCallsProvider =
    StreamProvider.family<List<ToolCallModel>, String>((ref, agentId) async* {
  final repo = await ref.watch(chatRepositoryProvider.future);
  yield* repo.watchToolCallsForAgent(agentId);
});

/// Active SSE subscription for a run.
final runStreamProvider =
    StreamProvider.family<SseEvent, RunStreamKey>((ref, key) async* {
  final repo = await ref.watch(chatRepositoryProvider.future);
  await for (final event in repo.streamRun(
    agentId: key.agentId,
    runId: key.runId,
    lastEventId: key.lastEventId,
  )) {
    await repo.persistSseEvent(
      agentId: key.agentId,
      runId: key.runId,
      event: event,
    );
    if (event is DoneEvent) {
      await repo.fetchUsageForRun(agentId: key.agentId, runId: key.runId);
    }
    yield event;
    if (event is DoneEvent || event is ErrorEvent) {
      break;
    }
  }
});

class RunStreamKey {
  const RunStreamKey({
    required this.agentId,
    required this.runId,
    this.lastEventId,
  });

  final String agentId;
  final String runId;
  final String? lastEventId;

  @override
  bool operator ==(Object other) =>
      other is RunStreamKey &&
      other.agentId == agentId &&
      other.runId == runId &&
      other.lastEventId == lastEventId;

  @override
  int get hashCode => Object.hash(agentId, runId, lastEventId);
}

class ChatState {
  const ChatState({
    this.composerText = '',
    this.isSending = false,
    this.currentRunId,
    this.errorMessage,
    this.isRunActive = false,
  });

  final String composerText;
  final bool isSending;
  final String? currentRunId;
  final String? errorMessage;
  final bool isRunActive;

  ChatState copyWith({
    String? composerText,
    bool? isSending,
    String? currentRunId,
    String? errorMessage,
    bool? isRunActive,
    bool clearError = false,
    bool clearRunId = false,
  }) {
    return ChatState(
      composerText: composerText ?? this.composerText,
      isSending: isSending ?? this.isSending,
      currentRunId: clearRunId ? null : (currentRunId ?? this.currentRunId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRunActive: isRunActive ?? this.isRunActive,
    );
  }
}

final chatStateProvider =
    NotifierProvider.family<ChatStateNotifier, ChatState, String>(
  ChatStateNotifier.new,
);

class ChatStateNotifier extends FamilyNotifier<ChatState, String> {
  @override
  ChatState build(String agentId) => const ChatState();

  void setComposerText(String text) {
    state = state.copyWith(composerText: text);
  }

  void setSending(bool sending) {
    state = state.copyWith(isSending: sending);
  }

  void setRunActive({required String runId, required bool active}) {
    state = state.copyWith(
      currentRunId: runId,
      isRunActive: active,
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isSending: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearComposer() {
    state = state.copyWith(composerText: '', clearError: true);
  }
}

final agentChatProvider =
    AsyncNotifierProvider.family<AgentChatNotifier, void, String>(
  AgentChatNotifier.new,
);

class AgentChatNotifier extends FamilyAsyncNotifier<void, String> {
  StreamSubscription<SseEvent>? _subscription;

  @override
  Future<void> build(String agentId) async {
    ref.onDispose(() => _subscription?.cancel());
    final agent = await ref.read(agentProvider(agentId).future);
    final runId = agent?.latestRunId;
    if (runId != null) {
      final run = await ref
          .read(agentRepositoryProvider.future)
          .then((r) => r.listRunsLocal(agentId))
          .then((runs) => runs.where((r) => r.runId == runId).firstOrNull);
      if (run != null && run.isRunning) {
        ref.read(chatStateProvider(agentId).notifier).setRunActive(
              runId: runId,
              active: true,
            );
        _attachStream(agentId, runId);
      }
    }
  }

  void _attachStream(String agentId, String runId) {
    _subscription?.cancel();
    final sub = ref.listen(
      runStreamProvider(RunStreamKey(agentId: agentId, runId: runId)),
      (_, next) {
        next.whenOrNull(
          data: (event) {
            if (event is DoneEvent || event is ErrorEvent) {
              ref.read(chatStateProvider(agentId).notifier).setRunActive(
                    runId: runId,
                    active: false,
                  );
            }
          },
          error: (e, _) {
            ref.read(chatStateProvider(agentId).notifier).setError(e.toString());
          },
        );
      },
    );
    ref.onDispose(sub.close);
  }

  Future<void> sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty) {
      return;
    }
    final agentId = arg;
    final chatNotifier = ref.read(chatStateProvider(agentId).notifier);
    final chatState = ref.read(chatStateProvider(agentId));

    if (chatState.isRunActive) {
      chatNotifier.setError('Agent is busy. Cancel the current run first.');
      return;
    }

    chatNotifier.setSending(true);

    final agentRepo = await ref.read(agentRepositoryProvider.future);
    final chatRepo = await ref.read(chatRepositoryProvider.future);

    final result = await agentRepo.createRun(
      agentId: agentId,
      prompt: prompt,
    );

    await result.fold(
      (failure) async => chatNotifier.setError(_failureMessage(failure)),
      (run) async {
        await chatRepo.insertUserMessage(runId: run.runId, content: prompt);
        chatNotifier.clearComposer();
        chatNotifier.setRunActive(runId: run.runId, active: true);
        _attachStream(agentId, run.runId);
        chatNotifier.setSending(false);
        await ref.read(agentProvider(agentId).notifier).refresh();
        await ref.read(agentListProvider.notifier).refresh();
      },
    );
  }

  Future<void> cancelCurrentRun() async {
    final agentId = arg;
    final runId = ref.read(chatStateProvider(agentId)).currentRunId;
    if (runId == null) {
      return;
    }
    final repo = await ref.read(agentRepositoryProvider.future);
    final result = await repo.cancelRun(agentId: agentId, runId: runId);
    result.fold(
      (failure) =>
          ref.read(chatStateProvider(agentId).notifier).setError(_failureMessage(failure)),
      (_) {
        ref.read(chatStateProvider(agentId).notifier).setRunActive(
              runId: runId,
              active: false,
            );
        _subscription?.cancel();
        ref.read(agentProvider(agentId).notifier).refresh();
        ref.read(agentListProvider.notifier).refresh();
      },
    );
  }

  String _failureMessage(AgentFailure failure) {
    return switch (failure) {
      AgentBusyFailure() => 'Agent is busy. Try again shortly.',
      AgentUnauthorizedFailure() => 'API key invalid. Check settings.',
      AgentNetworkFailure(:final message) => message,
      _ => 'Request failed: $failure',
    };
  }
}

/// First pinned project repo URL for new agent creation.
final defaultRepoUrlProvider = FutureProvider<String?>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  final pinned = await (db.select(db.pinnedProjects)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();
  return pinned.isEmpty ? null : pinned.first.repoUrl;
});

final modelsProvider = FutureProvider<ModelListPage>((ref) async {
  final repo = await ref.watch(agentRepositoryProvider.future);
  final result = await repo.listModels();
  return result.fold(
    (_) => const ModelListPage(models: []),
    (page) => page,
  );
});

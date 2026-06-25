import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/core/network/connectivity_service.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/chat/data/queued_prompt_service.dart';

final queuedPromptServiceProvider =
    FutureProvider<QueuedPromptService>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  return QueuedPromptService(db);
});

/// Drains pending queued prompts when connectivity returns.
final offlineQueueProcessorProvider = Provider<OfflineQueueProcessor>((ref) {
  return OfflineQueueProcessor(ref);
});

class OfflineQueueProcessor {
  OfflineQueueProcessor(this._ref);

  final Ref _ref;
  bool _processing = false;

  Future<int> processPending() async {
    if (_processing) {
      return 0;
    }
    _processing = true;
    try {
      final online = await _ref.read(connectivityServiceProvider).checkOnline();
      if (!online) {
        return 0;
      }

      final queue = await _ref.read(queuedPromptServiceProvider.future);
      final pending = await queue.listPending();
      var sent = 0;

      for (final item in pending) {
        final agentId = item.agentId;
        if (agentId == null || agentId.isEmpty) {
          await queue.markFailed(item.id, reason: 'missing_agent');
          continue;
        }

        final repo = await _ref.read(agentRepositoryProvider.future);
        final result = await repo.createRun(
          agentId: agentId,
          prompt: item.promptText,
          repoUrl: item.repoUrl,
        );

        await result.fold(
          (failure) => queue.markFailed(item.id, reason: failure.toString()),
          (_) async {
            await queue.markSent(item.id);
            sent++;
          },
        );
      }

      if (sent > 0) {
        await _ref.read(agentListProvider.notifier).refresh();
      }
      return sent;
    } finally {
      _processing = false;
    }
  }
}

final pendingQueueCountProvider = FutureProvider<int>((ref) async {
  final queue = await ref.watch(queuedPromptServiceProvider.future);
  return queue.pendingCount();
});

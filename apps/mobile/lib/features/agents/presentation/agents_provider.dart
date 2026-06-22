import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_repository_impl.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_repository.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_local_source.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_repository_impl.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_repository.dart';

final cursorApiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return storage.readKey(SecureStorageKeys.cursorApiKey);
});

final apiAgentRepositoryProvider = FutureProvider<api.AgentRepository>((ref) async {
  final key = await ref.watch(cursorApiKeyProvider.future);
  if (key == null || key.isEmpty) {
    throw StateError('Cursor API key not configured');
  }
  return api.AgentRepositoryImpl(CursorHttpClient(apiKey: key));
});

final agentLocalSourceProvider = FutureProvider<AgentLocalSource>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  return AgentLocalSource(db);
});

final agentRepositoryProvider = FutureProvider<AgentRepository>((ref) async {
  final apiRepo = await ref.watch(apiAgentRepositoryProvider.future);
  final local = await ref.watch(agentLocalSourceProvider.future);
  return AgentRepositoryImpl(apiRepository: apiRepo, localSource: local);
});

final runStreamServiceProvider = FutureProvider<RunStreamService>((ref) async {
  final key = await ref.watch(cursorApiKeyProvider.future);
  if (key == null || key.isEmpty) {
    throw StateError('Cursor API key not configured');
  }
  return RunStreamService(apiKey: key);
});

final chatRepositoryProvider = FutureProvider<ChatRepository>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  final stream = await ref.watch(runStreamServiceProvider.future);
  final apiRepo = await ref.watch(apiAgentRepositoryProvider.future);
  final local = ChatLocalSource(db);
  final agentLocal = await ref.watch(agentLocalSourceProvider.future);
  return ChatRepositoryImpl(
    database: db,
    streamService: stream,
    apiRepository: apiRepo,
    localSource: local,
    agentLocal: agentLocal,
  );
});

/// All agents from local DB; syncs from API on load and refresh.
final agentListProvider =
    AsyncNotifierProvider<AgentListNotifier, List<AgentSession>>(
  AgentListNotifier.new,
);

class AgentListNotifier extends AsyncNotifier<List<AgentSession>> {
  @override
  Future<List<AgentSession>> build() async {
    final repo = await ref.watch(agentRepositoryProvider.future);
    await repo.syncAgentsFromApi();
    return repo.listAgentsLocal();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(agentRepositoryProvider.future);
      await repo.syncAgentsFromApi();
      return repo.listAgentsLocal();
    });
  }
}

final agentProvider =
    AsyncNotifierProvider.family<AgentDetailNotifier, AgentSession?, String>(
  AgentDetailNotifier.new,
);

class AgentDetailNotifier extends FamilyAsyncNotifier<AgentSession?, String> {
  @override
  Future<AgentSession?> build(String agentId) async {
    final repo = await ref.watch(agentRepositoryProvider.future);
    final result = await repo.getAgent(agentId);
    return result.fold((_) => null, (a) => a);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(agentRepositoryProvider.future);
      final result = await repo.getAgent(arg);
      return result.fold((_) => null, (a) => a);
    });
  }
}

final activeAgentsCountProvider = Provider<int>((ref) {
  final agents = ref.watch(agentListProvider).valueOrNull ?? const [];
  return agents.where((a) => a.isActive).length;
});

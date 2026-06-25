import 'package:aivance_orchestrator/aivance_orchestrator.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:cursor_execution_provider/cursor_execution_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_api/github_api.dart';

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
  return storage.readCursorToken();
});

final providerRegistryProvider = Provider<ProviderRegistry>((ref) {
  return ProviderRegistry();
});

final executionProviderProvider =
    FutureProvider<ExecutionProvider>((ref) async {
  final key = await ref.watch(cursorApiKeyProvider.future);
  if (key == null || key.isEmpty) {
    throw StateError('Workspace connection not configured');
  }

  final registry = ref.watch(providerRegistryProvider);
  if (registry.isRegistered('cursor')) {
    return registry.get('cursor');
  }

  final cursorProvider = CursorExecutionProvider(
    agents: api.AgentRepositoryImpl(CursorHttpClient(apiKey: key)),
    streamService: RunStreamService(apiKey: key),
  );
  registry.register(cursorProvider, isDefault: true);
  return cursorProvider;
});

final agentLocalSourceProvider = FutureProvider<AgentLocalSource>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  return AgentLocalSource(db);
});

final githubAccessTokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return storage.readGithubToken();
});

final githubRepositoryProvider = FutureProvider<GithubRepository?>((ref) async {
  final token = await ref.watch(githubAccessTokenProvider.future);
  if (token == null || token.isEmpty) {
    return null;
  }
  return GithubRepositoryImpl(GithubHttpClient(accessToken: token));
});

final commandOrchestratorProvider =
    FutureProvider<AgentCommandOrchestrator>((ref) async {
  final execution = await ref.watch(executionProviderProvider.future);
  final github = await ref.watch(githubRepositoryProvider.future);
  return AgentCommandOrchestrator(
    execution: execution,
    github: github,
  );
});

final agentRepositoryProvider = FutureProvider<AgentRepository>((ref) async {
  final execution = await ref.watch(executionProviderProvider.future);
  final local = await ref.watch(agentLocalSourceProvider.future);
  final orchestrator = await ref.watch(commandOrchestratorProvider.future);
  return AgentRepositoryImpl(
    executionProvider: execution,
    localSource: local,
    orchestrator: orchestrator,
  );
});

final chatRepositoryProvider = FutureProvider<ChatRepository>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  final execution = await ref.watch(executionProviderProvider.future);
  final local = ChatLocalSource(db);
  final agentLocal = await ref.watch(agentLocalSourceProvider.future);
  return ChatRepositoryImpl(
    database: db,
    executionProvider: execution,
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

final repositoriesProvider = FutureProvider<List<String>>((ref) async {
  final execution = await ref.watch(executionProviderProvider.future);
  final result = await execution.listRepositories();
  return result.fold(
    (f) => throw StateError(f.message),
    (page) => page.repositories
        .map((repo) => RepoUrlUtils.normalize(repo.url))
        .where((url) => url.isNotEmpty)
        .toList(),
  );
});

final modelsProvider = FutureProvider<api.ModelListPage>((ref) async {
  final repo = await ref.watch(agentRepositoryProvider.future);
  final result = await repo.listModels();
  return result.fold(
    (_) => const api.ModelListPage(models: []),
    (page) => page,
  );
});

final defaultRepoUrlProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  final lastUsed = await storage.readKey(SecureStorageKeys.lastUsedRepoUrl);
  if (lastUsed != null && lastUsed.isNotEmpty) {
    return lastUsed;
  }
  final repos = await ref.watch(repositoriesProvider.future);
  return repos.isEmpty ? null : repos.first;
});

Future<void> saveLastUsedRepoUrl(WidgetRef ref, String repoUrl) async {
  final storage = ref.read(secureStorageServiceProvider);
  await storage.writeKey(SecureStorageKeys.lastUsedRepoUrl, repoUrl);
}

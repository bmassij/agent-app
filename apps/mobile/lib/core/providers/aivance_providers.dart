import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';

/// Aivance facade providers (M2). Legacy names remain with @Deprecated.

@Deprecated('Use taskListProvider instead. Removed in M4.')
final taskListProvider = agentListProvider;

@Deprecated('Use taskDetailProvider instead. Removed in M4.')
final taskDetailProvider = agentProvider;

@Deprecated('Use orchestratorProvider instead. Removed in M4.')
final orchestratorProvider = commandOrchestratorProvider;

@Deprecated('Use cursorConnectionProvider instead. Removed in M4.')
final cursorConnectionProvider = cursorApiKeyProvider;

@Deprecated('Use executionRepositoryProvider instead. Removed in M4.')
final executionRepositoryProvider = apiAgentRepositoryProvider;

/// Active worker count facade.
final activeWorkersCountProvider = Provider<int>((ref) {
  final agents =
      ref.watch(taskListProvider).valueOrNull ?? const <AgentSession>[];
  return agents.where((a) => a.isActive).length;
});

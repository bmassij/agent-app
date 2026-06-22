import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/chat_provider.dart';

Future<void> showNewAgentSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const NewAgentSheet(),
  );
}

class NewAgentSheet extends ConsumerStatefulWidget {
  const NewAgentSheet({super.key});

  @override
  ConsumerState<NewAgentSheet> createState() => _NewAgentSheetState();
}

class _NewAgentSheetState extends ConsumerState<NewAgentSheet> {
  final _promptController = TextEditingController();
  final _repoController = TextEditingController();
  String? _selectedModel;
  bool _autoCreatePr = true;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final prompt = _promptController.text.trim();
    final repo = _repoController.text.trim();
    if (prompt.isEmpty || repo.isEmpty) {
      setState(() => _error = 'Prompt and repository URL are required.');
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    final repoApi = await ref.read(agentRepositoryProvider.future);
    final projectId = Uri.tryParse(repo)?.pathSegments.take(2).join('/') ??
        'default';

    final result = await repoApi.createAgent(
      projectId: projectId,
      repoUrl: repo,
      prompt: prompt,
      model: _selectedModel,
      autoCreatePr: _autoCreatePr,
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) => setState(() {
        _isCreating = false;
        _error = failure.toString();
      }),
      (created) async {
        await ref.read(agentListProvider.notifier).refresh();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
        context.push(Routes.agentChat(created.agentId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final modelsAsync = ref.watch(modelsProvider);
    final defaultRepo = ref.watch(defaultRepoUrlProvider);

    defaultRepo.whenData((url) {
      if (url != null && _repoController.text.isEmpty) {
        _repoController.text = url;
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New agent', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _repoController,
            decoration: const InputDecoration(
              labelText: 'Repository URL',
              hintText: 'https://github.com/owner/repo',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Prompt',
              hintText: 'What should the agent do?',
            ),
          ),
          const SizedBox(height: 12),
          modelsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (page) {
              if (page.models.isEmpty) {
                return const SizedBox.shrink();
              }
              return DropdownButtonFormField<String>(
                initialValue: _selectedModel,
                decoration: const InputDecoration(labelText: 'Model'),
                items: page.models
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.name ?? m.id),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedModel = v),
              );
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-create PR'),
            value: _autoCreatePr,
            onChanged: (v) => setState(() => _autoCreatePr = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isCreating ? null : _create,
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create agent'),
          ),
        ],
      ),
    );
  }
}

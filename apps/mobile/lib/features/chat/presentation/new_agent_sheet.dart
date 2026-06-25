import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';

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
  final _manualRepoController = TextEditingController();
  String? _selectedRepoUrl;
  String? _selectedModel;
  bool _autoCreatePr = false;
  bool _isCreating = false;
  String? _error;
  bool _manualRepoInitialized = false;

  @override
  void dispose() {
    _promptController.dispose();
    _manualRepoController.dispose();
    super.dispose();
  }

  void _autoSelectRepo(List<String> repos, String? preferred) {
    if (_selectedRepoUrl != null) {
      return;
    }
    if (preferred != null && repos.contains(preferred)) {
      _selectedRepoUrl = preferred;
      return;
    }
    if (repos.isNotEmpty) {
      _selectedRepoUrl = repos.first;
    }
  }

  String? _resolvedRepoUrl() {
    final selected = _selectedRepoUrl?.trim();
    if (selected != null && selected.isNotEmpty) {
      return RepoUrlUtils.normalize(selected);
    }
    final manual = _manualRepoController.text.trim();
    if (manual.isNotEmpty) {
      return RepoUrlUtils.normalize(manual);
    }
    return null;
  }

  Future<void> _create() async {
    final prompt = _promptController.text.trim();
    final repo = _resolvedRepoUrl();
    if (prompt.isEmpty) {
      setState(() => _error = 'Describe what you want done.');
      return;
    }
    if (repo == null || repo.isEmpty) {
      setState(
        () => _error =
            'Pick a repository or paste a GitHub URL (https://github.com/owner/repo).',
      );
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    final repoApi = await ref.read(agentRepositoryProvider.future);
    final projectId =
        Uri.tryParse(repo)?.pathSegments.take(2).join('/') ?? 'default';

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
        await saveLastUsedRepoUrl(ref, repo);
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
    final reposAsync = ref.watch(repositoriesProvider);
    final defaultRepo = ref.watch(defaultRepoUrlProvider);

    defaultRepo.whenData((preferred) {
      if (!_manualRepoInitialized &&
          preferred != null &&
          preferred.isNotEmpty) {
        _manualRepoInitialized = true;
        _manualRepoController.text = preferred;
      }
    });

    reposAsync.whenData((repos) {
      final preferred = defaultRepo.valueOrNull;
      final previous = _selectedRepoUrl;
      _autoSelectRepo(repos, preferred);
      if (_selectedRepoUrl != previous && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
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
          Text('New command', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            autofocus: true,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Command',
              hintText: 'Bijv. "Fix deze bug" of "Maak een PR"',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          reposAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Could not load repository list. Paste your repo URL below.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 8),
                _manualRepoField(),
              ],
            ),
            data: (repos) {
              if (repos.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'No repositories available. Connect GitHub in your '
                      'workspace settings, or paste a repo URL:',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    _manualRepoField(),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRepoUrl,
                    decoration: const InputDecoration(labelText: 'Repository'),
                    items: repos
                        .map(
                          (url) => DropdownMenuItem(
                            value: url,
                            child: Text(
                              url,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRepoUrl = v),
                  ),
                  const SizedBox(height: 8),
                  _manualRepoField(
                    label: 'Or paste another repo URL',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Advanced options'),
            children: [
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
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
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
                : const Text('Start command'),
          ),
        ],
      ),
    );
  }

  Widget _manualRepoField({String label = 'GitHub repository URL'}) {
    return TextField(
      controller: _manualRepoController,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'https://github.com/owner/repo',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.url,
      onChanged: (_) => setState(() => _selectedRepoUrl = null),
    );
  }
}

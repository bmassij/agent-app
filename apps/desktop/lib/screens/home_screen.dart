import 'package:aivance_orchestrator/aivance_orchestrator.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:cursor_commander_desktop/screens/chat_screen.dart';
import 'package:cursor_commander_desktop/services/cursor_session.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.session, super.key});

  final CursorSession session;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskInfo> _agents = [];
  List<String> _repos = [];
  bool _loading = true;
  String? _error;
  String? _lastContextPreview;

  final _promptController = TextEditingController();
  String? _selectedRepo;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final agents = await widget.session.listAgents();
      final repos = await widget.session.listRepoUrls();
      setState(() {
        _agents = agents;
        _repos = repos;
        _selectedRepo ??= repos.isNotEmpty ? repos.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _createCommand() async {
    final prompt = _promptController.text.trim();
    final repo = _selectedRepo;
    if (prompt.isEmpty || repo == null) {
      return;
    }
    setState(() => _creating = true);
    try {
      final created = await widget.session.dispatchCommand(
        CommandInput(userPrompt: prompt, repoUrl: repo),
      );
      _promptController.clear();
      if (!mounted) {
        return;
      }
      setState(() => _lastContextPreview = created.contextSummary);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(
            session: widget.session,
            agentId: created.agentId,
            repoUrl: repo,
            initialRunId: created.runId,
            title: prompt.length > 40 ? '${prompt.substring(0, 40)}…' : prompt,
          ),
        ),
      );
      await _refresh();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursor Commander'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(flex: 2, child: _buildCommandPanel(context)),
                const VerticalDivider(width: 1),
                Expanded(flex: 3, child: _buildAgentList(context)),
              ],
            ),
    );
  }

  Widget _buildCommandPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Opdracht', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Korte prompts werken — context wordt automatisch verzameld.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: TextField(
              controller: _promptController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText:
                    'Bijv. "Fix deze bug" of "Vertel me over dit project"',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_lastContextPreview != null) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('Laatste context-briefing'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SelectableText(
                    _lastContextPreview!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (_repos.isEmpty)
            Text(
              'Geen repo\'s — koppel GitHub op cursor.com/settings',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedRepo,
              decoration: const InputDecoration(
                labelText: 'Repository (auto-default)',
                border: OutlineInputBorder(),
              ),
              items: _repos
                  .map(
                    (u) => DropdownMenuItem(
                      value: u,
                      child: Text(u, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedRepo = v),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _creating || _repos.isEmpty ? null : _createCommand,
            child: _creating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Start opdracht'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentList(BuildContext context) {
    if (_agents.isEmpty) {
      return const Center(child: Text('Nog geen agents — start een opdracht.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _agents.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final agent = _agents[index];
        final repo = _selectedRepo ?? (_repos.isNotEmpty ? _repos.first : '');
        return ListTile(
          title: Text(agent.name ?? agent.taskId),
          subtitle: Text('${agent.status} · ${agent.taskId}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            if (repo.isEmpty) {
              return;
            }
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChatScreen(
                  session: widget.session,
                  agentId: agent.taskId,
                  repoUrl: repo,
                  initialRunId: agent.latestRunId,
                  title: agent.name ?? agent.taskId,
                ),
              ),
            );
            await _refresh();
          },
        );
      },
    );
  }
}

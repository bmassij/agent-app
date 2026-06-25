import 'dart:async';

import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:cursor_commander_desktop/services/cursor_session.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.session,
    required this.agentId,
    required this.repoUrl,
    required this.title,
    this.initialRunId,
    super.key,
  });

  final CursorSession session;
  final String agentId;
  final String repoUrl;
  final String title;
  final String? initialRunId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <_ChatLine>[];
  final _composer = TextEditingController();
  final _scroll = ScrollController();

  StreamSubscription<TaskStreamEvent>? _sub;
  bool _runActive = false;
  bool _sending = false;
  String? _error;
  String _assistantBuffer = '';

  @override
  void initState() {
    super.initState();
    final runId = widget.initialRunId;
    if (runId != null && runId.isNotEmpty) {
      _attachStream(runId);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _attachStream(String runId) {
    _sub?.cancel();
    setState(() {
      _runActive = true;
      _assistantBuffer = '';
      _error = null;
    });
    _sub = widget.session
        .watchRun(agentId: widget.agentId, runId: runId)
        .listen(_onEvent, onError: (Object e) {
      setState(() {
        _error = e.toString();
        _runActive = false;
      });
    });
  }

  void _onEvent(TaskStreamEvent event) {
    if (event is AssistantDeltaStreamEvent) {
      setState(() {
        _assistantBuffer += event.delta;
        _syncAssistantBubble();
      });
      _scrollToEnd();
    } else if (event is ResultStreamEvent && event.text.isNotEmpty) {
      setState(() {
        _assistantBuffer = event.text;
        _syncAssistantBubble();
        _runActive = false;
      });
    } else if (event is DoneStreamEvent) {
      setState(() => _runActive = false);
    } else if (event is ErrorStreamEvent) {
      setState(() {
        _error = event.message;
        _runActive = false;
      });
    } else if (event is StatusStreamEvent) {
      setState(() {
        _messages.add(_ChatLine.system('Status: ${event.status}'));
      });
    }
  }

  void _syncAssistantBubble() {
    if (_messages.isNotEmpty && _messages.last.isAssistant) {
      _messages[_messages.length - 1] = _ChatLine.assistant(_assistantBuffer);
    } else {
      _messages.add(_ChatLine.assistant(_assistantBuffer));
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _runActive) {
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
      _messages.add(_ChatLine.user(text));
      _composer.clear();
    });
    _scrollToEnd();
    try {
      final run = await widget.session.sendFollowUp(
        agentId: widget.agentId,
        prompt: text,
        repoUrl: widget.repoUrl,
      );
      _attachStream(run.runId);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_runActive) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final line = _messages[index];
                if (line.isSystem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      line.text,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                final isUser = line.isUser;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF00B4D8).withValues(alpha: 0.25)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(line.text),
                  ),
                );
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composer,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Vervolgopdracht…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sending || _runActive ? null : _send,
                  child: const Text('Stuur'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatLine {
  _ChatLine._(this.text,
      {required this.isUser,
      required this.isAssistant,
      required this.isSystem});

  factory _ChatLine.user(String text) =>
      _ChatLine._(text, isUser: true, isAssistant: false, isSystem: false);

  factory _ChatLine.assistant(String text) =>
      _ChatLine._(text, isUser: false, isAssistant: true, isSystem: false);

  factory _ChatLine.system(String text) =>
      _ChatLine._(text, isUser: false, isAssistant: false, isSystem: true);

  final String text;
  final bool isUser;
  final bool isAssistant;
  final bool isSystem;
}

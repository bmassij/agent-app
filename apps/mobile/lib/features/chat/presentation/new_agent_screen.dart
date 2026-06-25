import 'package:flutter/material.dart';

import 'package:cursor_mobile_commander/features/chat/presentation/new_agent_sheet.dart';

/// Full-screen wrapper for new command creation (route `/home/agents/new`).
class NewAgentScreen extends StatelessWidget {
  const NewAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New command')),
      body: const SafeArea(child: NewAgentSheet()),
    );
  }
}

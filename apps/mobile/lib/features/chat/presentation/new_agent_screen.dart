import 'package:flutter/material.dart';

import 'package:cursor_mobile_commander/features/chat/presentation/new_agent_sheet.dart';

/// Full-screen wrapper for new agent creation (route `/home/agents/new`).
class NewAgentScreen extends StatelessWidget {
  const NewAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: NewAgentSheet()),
    );
  }
}

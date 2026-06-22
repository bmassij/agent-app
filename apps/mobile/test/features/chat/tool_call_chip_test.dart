import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/tool_call_chip.dart';

void main() {
  testWidgets('ToolCallChip expands and collapses', (tester) async {
    final tool = ToolCallModel(
      callId: 'c1',
      runId: 'r1',
      toolName: 'read_file',
      status: 'completed',
      argsJson: '{"path":"main.dart"}',
      resultJson: '{"ok":true}',
      startedAt: DateTime.utc(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ToolCallChip(toolCall: tool),
        ),
      ),
    );

    expect(find.text('read_file'), findsOneWidget);
    expect(find.text('Args'), findsNothing);

    await tester.tap(find.text('read_file'));
    await tester.pumpAndSettle();

    expect(find.text('Args'), findsOneWidget);
    expect(find.text('Result'), findsOneWidget);
  });
}

import 'package:cursor_commander_desktop/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('setup screen shows API key field', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SetupScreen(onKeySaved: (_) {}),
      ),
    );
    expect(find.text('Aivance Dev Console'), findsOneWidget);
    expect(find.text('Toegangscode'), findsOneWidget);
    expect(find.text('Verbinden'), findsOneWidget);
  });
}

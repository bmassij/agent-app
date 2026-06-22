import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/features/onboarding/presentation/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen shows title and get started button',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WelcomeScreen()),
    );

    expect(find.text('Cursor Mobile Commander'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}

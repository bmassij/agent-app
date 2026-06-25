import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/features/onboarding/presentation/connect_cursor_screen.dart';

void main() {
  testWidgets('ConnectCursorScreen shows enter API key button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConnectCursorScreen()),
    );

    expect(find.text('Connect workspace'), findsOneWidget);
    expect(find.text('Scan QR code'), findsOneWidget);
    expect(find.text('Enter connection manually'), findsOneWidget);
  });
}

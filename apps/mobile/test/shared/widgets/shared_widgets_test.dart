import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';
import 'package:cursor_mobile_commander/shared/widgets/offline_banner.dart';

void main() {
  group('LoadingSpinner', () {
    testWidgets('renders progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingSpinner())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows optional message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingSpinner(message: 'Please wait')),
        ),
      );

      expect(find.text('Please wait'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('renders message and retry button', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Something failed',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something failed'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });

  group('OfflineBanner', () {
    testWidgets('renders offline message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflineBanner())),
      );

      expect(find.textContaining('offline'), findsOneWidget);
    });
  });
}

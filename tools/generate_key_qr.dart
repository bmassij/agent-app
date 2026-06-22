// QR helper for transferring Cursor API keys to the mobile app.
//
// Usage: dart run tools/generate_key_qr.dart --key=YOUR_CURSOR_API_KEY
//
// Requires: pub add qr (run from tools/ or project root with path).

import 'dart:io';

void main(List<String> args) {
  final keyArg = args.firstWhere(
    (a) => a.startsWith('--key='),
    orElse: () => '',
  );
  if (keyArg.isEmpty) {
    stderr.writeln('Usage: dart run tools/generate_key_qr.dart --key=YOUR_KEY');
    exit(1);
  }
  final key = keyArg.substring('--key='.length).trim();
  if (key.isEmpty) {
    stderr.writeln('API key must not be empty');
    exit(1);
  }
  final payload = 'cursormc://auth?key=${Uri.encodeComponent(key)}';
  stdout.writeln('Scan this payload in Cursor Mobile Commander:');
  stdout.writeln(payload);
  stdout.writeln('');
  stdout.writeln(
    'Tip: paste the URL into a QR generator, or use a terminal QR tool.',
  );
}

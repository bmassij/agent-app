// Prints a scannable QR for transferring a Cursor API key to the mobile app.
//
// Usage:
//   cd tools && dart pub get
//   dart run generate_key_qr.dart --key=YOUR_CURSOR_API_KEY
//
// The app accepts: cursormc://auth?key=... or a raw cursor_/crsr_ key.

import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

void main(List<String> args) {
  final keyArg = args.firstWhere(
    (a) => a.startsWith('--key='),
    orElse: () => '',
  );
  if (keyArg.isEmpty) {
    stderr.writeln('Usage: dart run generate_key_qr.dart --key=YOUR_KEY');
    exit(1);
  }
  final key = keyArg.substring('--key='.length).trim();
  if (key.isEmpty) {
    stderr.writeln('Access code must not be empty');
    exit(1);
  }

  final payload = 'cursormc://auth?key=${Uri.encodeComponent(key)}';

  stdout.writeln('Aivance — workspace connection QR');
  stdout.writeln('Payload: $payload');
  stdout.writeln('');
  stdout.writeln(_toTerminalAscii(payload));
  stdout.writeln('');

  final pngPath = _writePng(payload);
  stdout.writeln('PNG saved: $pngPath');
  stdout.writeln('');
  stdout.writeln('On your phone: Connect workspace → Scan QR code → point at this QR.');

  if (Platform.isWindows) {
    Process.runSync('cmd', ['/c', 'start', '', pngPath]);
  } else if (Platform.isMacOS) {
    Process.runSync('open', [pngPath]);
  } else if (Platform.isLinux) {
    Process.runSync('xdg-open', [pngPath]);
  }
}

String _toTerminalAscii(String data) {
  final qrCode = QrCode(4, QrErrorCorrectLevel.L)..addData(data);
  final image = QrImage(qrCode);
  final buffer = StringBuffer();
  for (var y = 0; y < image.moduleCount; y++) {
    for (var x = 0; x < image.moduleCount; x++) {
      buffer.write(image.isDark(y, x) ? '██' : '  ');
    }
    buffer.writeln();
  }
  return buffer.toString();
}

String _writePng(String data) {
  final qrCode = QrCode(4, QrErrorCorrectLevel.L)..addData(data);
  final qrImage = QrImage(qrCode);
  const pixelSize = 8;
  const padding = 4;
  final modules = qrImage.moduleCount;
  final size = (modules + padding * 2) * pixelSize;
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  for (var y = 0; y < modules; y++) {
    for (var x = 0; x < modules; x++) {
      final color = qrImage.isDark(y, x)
          ? img.ColorRgb8(0, 0, 0)
          : img.ColorRgb8(255, 255, 255);
      for (var py = 0; py < pixelSize; py++) {
        for (var px = 0; px < pixelSize; px++) {
          image.setPixel(
            (x + padding) * pixelSize + px,
            (y + padding) * pixelSize + py,
            color,
          );
        }
      }
    }
  }

  final path =
      '${Directory.systemTemp.path}${Platform.pathSeparator}cursor_api_key_qr.png';
  File(path).writeAsBytesSync(img.encodePng(image));
  return path;
}

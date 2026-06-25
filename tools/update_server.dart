import 'dart:convert';
import 'dart:io';

/// Serves `update.json` and APK files for in-app OTA updates on the local network.
///
/// Usage (from repo `tools/` folder):
///   dart run update_server.dart
///
/// Keep this running on your PC while the phone checks for updates.
Future<void> main() async {
  final port = int.tryParse(
        Platform.environment['UPDATE_PORT'] ?? '',
      ) ??
      8765;
  final updatesDir = Directory('updates');
  if (!updatesDir.existsSync()) {
    updatesDir.createSync(recursive: true);
  }

  final ip = await _localIpv4();
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Aivance — update server');
  stdout.writeln('Serving: ${updatesDir.absolute.path}');
  stdout.writeln('Phone URL: http://$ip:$port');
  stdout.writeln('Manifest:  http://$ip:$port/update.json');
  stdout.writeln('Press Ctrl+C to stop.\n');

  await for (final request in server) {
    try {
      await _handle(request, updatesDir);
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error: $e')
        ..close();
    }
  }
}

Future<void> _handle(HttpRequest request, Directory updatesDir) async {
  var path = request.uri.path;
  if (path == '/' || path.isEmpty) {
    path = '/update.json';
  }

  final file = File('${updatesDir.path}${path.replaceAll('/', Platform.pathSeparator)}');
  if (!file.existsSync()) {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Not found: $path')
      ..close();
    return;
  }

  final bytes = await file.readAsBytes();
  if (path.endsWith('.json')) {
    request.response.headers.contentType = ContentType.json;
  } else if (path.endsWith('.apk')) {
    request.response.headers.contentType =
        ContentType('application', 'vnd.android.package-archive');
  } else {
    request.response.headers.contentType = ContentType.binary;
  }

  request.response
    ..headers.add('Access-Control-Allow-Origin', '*')
    ..add(bytes)
    ..close();
}

Future<String> _localIpv4() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLinkLocal: false,
  );
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback) {
        return addr.address;
      }
    }
  }
  return '127.0.0.1';
}

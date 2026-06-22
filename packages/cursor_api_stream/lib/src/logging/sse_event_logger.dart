/// Logs raw SSE lines for schema verification (debug / Sprint 3 requirement).
///
/// Never log API keys or bearer tokens. Raw event payloads only.
class SseEventLogger {
  SseEventLogger({this.enabled = true, void Function(String line)? sink})
      : _sink = sink ?? _defaultSink;

  final bool enabled;
  final void Function(String line) _sink;

  final List<String> _buffer = [];

  List<String> get loggedLines => List.unmodifiable(_buffer);

  void logRawLine(String line) {
    if (!enabled || line.trim().isEmpty) {
      return;
    }
    if (line.startsWith('Authorization') || line.contains('Bearer ')) {
      return;
    }
    _buffer.add(line);
    _sink('[SSE] $line');
  }

  void logChunk(String chunk) {
    for (final line in chunk.split('\n')) {
      logRawLine(line);
    }
  }

  void clear() => _buffer.clear();

  static void _defaultSink(String line) {
    assert(() {
      // ignore: avoid_print
      print(line);
      return true;
    }());
  }
}

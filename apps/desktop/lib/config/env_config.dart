import 'dart:io';

/// Loads [CURSOR_API_KEY] from environment or repo `.env` file.
class EnvConfig {
  static String? loadGithubToken() => _loadVar('GITHUB_TOKEN');

  static String? _loadVar(String name) {
    final fromEnv = Platform.environment[name];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return fromEnv.trim();
    }

    for (final path in _candidateEnvPaths()) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      for (final line in file.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          continue;
        }
        if (trimmed.startsWith('$name=')) {
          final value = trimmed.substring('$name='.length).trim();
          if (value.isNotEmpty) {
            return value.replaceAll(RegExp(r'''^["']|["']$'''), '');
          }
        }
      }
    }
    return null;
  }

  static String? loadApiKey() {
    final fromEnv = Platform.environment['CURSOR_API_KEY'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return fromEnv.trim();
    }

    for (final path in _candidateEnvPaths()) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      for (final line in file.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          continue;
        }
        if (trimmed.startsWith('CURSOR_API_KEY=')) {
          final value = trimmed.substring('CURSOR_API_KEY='.length).trim();
          if (value.isNotEmpty && value != 'crsr_your_key_here') {
            return value.replaceAll(RegExp(r'''^["']|["']$'''), '');
          }
        }
      }
    }
    return null;
  }

  static List<String> _candidateEnvPaths() {
    final cwd = Directory.current.path;
    return [
      r'd:\AI\agent app\cursor-mobile-commander\.env',
      '$cwd\\.env',
      '$cwd\\..\\.env',
      '$cwd\\..\\..\\.env',
      '${Platform.environment['USERPROFILE'] ?? ''}\\.cursor_mobile_commander\\.env',
    ].where((p) => p.isNotEmpty).toList();
  }
}

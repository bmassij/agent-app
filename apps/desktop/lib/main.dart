import 'package:cursor_commander_desktop/config/env_config.dart';
import 'package:cursor_commander_desktop/screens/home_screen.dart';
import 'package:cursor_commander_desktop/screens/setup_screen.dart';
import 'package:cursor_commander_desktop/services/cursor_session.dart';
import 'package:cursor_commander_desktop/theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CommanderDesktopApp());
}

class CommanderDesktopApp extends StatefulWidget {
  const CommanderDesktopApp({super.key});

  @override
  State<CommanderDesktopApp> createState() => _CommanderDesktopAppState();
}

class _CommanderDesktopAppState extends State<CommanderDesktopApp> {
  CursorSession? _session;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final key = EnvConfig.loadApiKey();
    if (key == null) {
      setState(() {
        _loading = false;
        _error = 'Geen verbinding. Zet CURSOR_API_KEY in .env of hieronder.';
      });
      return;
    }
    try {
      final session = CursorSession(
        apiKey: key,
        githubToken: EnvConfig.loadGithubToken(),
      );
      await session.validate();
      setState(() {
        _session = session;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Verbinding ongeldig: $e';
      });
    }
  }

  void _onKeySaved(String key) {
    setState(() {
      _loading = true;
      _error = null;
    });
    CursorSession(apiKey: key, githubToken: EnvConfig.loadGithubToken())
        .validate()
        .then((_) {
      setState(() {
        _session = CursorSession(
          apiKey: key,
          githubToken: EnvConfig.loadGithubToken(),
        );
        _loading = false;
      });
    }).catchError((Object e) {
      setState(() {
        _loading = false;
        _error = 'Ongeldige verbinding: $e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aivance Dev Console',
      theme: DesktopTheme.dark,
      debugShowCheckedModeBanner: false,
      home: _loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _session != null
              ? HomeScreen(session: _session!)
              : SetupScreen(
                  error: _error,
                  onKeySaved: _onKeySaved,
                ),
    );
  }
}

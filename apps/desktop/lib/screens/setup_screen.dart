import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    required this.onKeySaved,
    this.error,
    super.key,
  });

  final void Function(String key) onKeySaved;
  final String? error;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cursor Commander',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Plak je Cursor API key of zet CURSOR_API_KEY in '
                  'cursor-mobile-commander/.env',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (widget.error != null) ...[
                  Text(
                    widget.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _controller,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'API key',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final key = _controller.text.trim();
                    if (key.isNotEmpty) {
                      widget.onKeySaved(key);
                    }
                  },
                  child: const Text('Verbinden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

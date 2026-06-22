import 'package:flutter/material.dart';

/// Generic placeholder for routes not yet implemented.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — not yet implemented')),
    );
  }
}

import 'package:flutter/material.dart';

/// Built-in prompt templates (Sprint 6 will expand with custom templates).
abstract final class BuiltInTemplates {
  static const List<(String name, String prompt)> items = [
    ('Fix bug', 'Find and fix the bug described in the issue.'),
    ('Add tests', 'Add unit tests for the changed modules.'),
    ('Refactor', 'Refactor for clarity without changing behavior.'),
    ('Review PR', 'Review the latest changes and suggest improvements.'),
  ];
}

/// Template picker bottom sheet.
class TemplatePickerSheet extends StatelessWidget {
  const TemplatePickerSheet({
    required this.onSelected,
    super.key,
  });

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (final item in BuiltInTemplates.items)
          ListTile(
            title: Text(item.$1),
            subtitle: Text(item.$2, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.of(context).pop();
              onSelected(item.$2);
            },
          ),
      ],
    );
  }
}

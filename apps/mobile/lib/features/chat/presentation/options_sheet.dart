import 'package:flutter/material.dart';

/// Agent creation options (branch, PR toggles).
class OptionsSheet extends StatefulWidget {
  const OptionsSheet({
    required this.autoCreatePr,
    required this.onAutoCreatePrChanged,
    this.workOnCurrentBranch = false,
    required this.onWorkOnCurrentBranchChanged,
    super.key,
  });

  final bool autoCreatePr;
  final ValueChanged<bool> onAutoCreatePrChanged;
  final bool workOnCurrentBranch;
  final ValueChanged<bool> onWorkOnCurrentBranchChanged;

  @override
  State<OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<OptionsSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text('Auto-create PR'),
          value: widget.autoCreatePr,
          onChanged: widget.onAutoCreatePrChanged,
        ),
        SwitchListTile(
          title: const Text('Work on current branch'),
          value: widget.workOnCurrentBranch,
          onChanged: widget.onWorkOnCurrentBranchChanged,
        ),
      ],
    );
  }
}
